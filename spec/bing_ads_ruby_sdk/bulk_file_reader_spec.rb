require "stringio"
require "zlib"
require "zip"
require "bing_ads_ruby_sdk/bulk_file_reader"

RSpec.describe BingAdsRubySdk::BulkFileReader do
  let(:csv) { "\uFEFFType,Client Id,Campaign\nCampaign,sdk-test,SDK Bulk Test\n" }
  let(:report_csv) do
    <<~CSV
      Report Name: SDK Report
      Report Time: 8/1/2026,9/3/2026
      Report Aggregation: Daily
      Rows: 1

      TimePeriod,AccountId,Impressions,Clicks,Spend
      2026-08-02,123456789,1,0,0.00
    CSV
  end

  describe "#to_csv" do
    it "reads plain UTF-8 CSV and removes the BOM" do
      rows = described_class.new(csv).to_csv

      expect(rows.headers).to eq(["Type", "Client Id", "Campaign"])
      expect(rows.first["Client Id"]).to eq("sdk-test")
    end

    it "skips instrumentation work when no callback is registered" do
      expect(Process).not_to receive(:clock_gettime)
      expect(BingAdsRubySdk::BulkFileReader::ProcessMetrics).not_to receive(:max_rss_bytes)

      rows = described_class.new(csv).to_csv

      expect(rows.headers).to eq(["Type", "Client Id", "Campaign"])
    end

    it "reports parsing metrics through the instrumentation callback" do
      measurements = []

      described_class.new(csv, instrumentation: ->(metrics) { measurements << metrics }).to_csv

      expect(measurements.length).to eq(3)
      expect(measurements.find { |metrics| metrics[:operation] == :to_csv }).to include(
        operation: :to_csv,
        wall_time_seconds: be_a(Float),
        cpu_time_seconds: be_a(Float),
        rss_max_bytes_before: be_a(Integer),
        rss_max_bytes_after: be_a(Integer),
        rss_max_bytes_delta: be_a(Integer)
      )
    end

    it "reports decode lifecycle events" do
      events = []

      described_class.new(csv, instrumentation: ->(event) { events << event }).to_csv

      expect(events.map { |event| event[:event] }).to include(:decode_start, :decode_finish)
      expect(events.find { |event| event[:event] == :decode_finish }).to include(
        event: :decode_finish,
        compression: :none,
        input_bytes: csv.bytesize,
        output_bytes: csv.bytesize - "\uFEFF".bytesize,
        duration_ms: be_a(Float),
        success: true,
        error_class: nil
      )
    end

    it "reports the unzip lifecycle event" do
      zip = Zip::OutputStream.write_buffer do |archive|
        archive.put_next_entry("campaign.csv")
        archive.write(csv)
      end
      events = []

      described_class.new(zip.string, instrumentation: ->(event) { events << event }).to_csv

      unzip = events.find { |event| event[:event] == :unzip_finish }
      expect(unzip).to include(
        compression: :zip,
        input_bytes: zip.string.bytesize,
        output_bytes: csv.bytesize,
        duration_ms: be_a(Float),
        success: true,
        error_class: nil
      )
    end

    it "continues parsing when instrumentation fails" do
      reader = described_class.new(csv, instrumentation: ->(_) { raise "telemetry unavailable" })

      expect(reader.to_csv.first["Campaign"]).to eq("SDK Bulk Test")
    end

    it "streams report CSV rows" do
      expect(CSV).not_to receive(:parse)

      described_class.new(report_csv).to_csv
    end

    it "yields rows without building a table" do
      rows = []

      described_class.new(csv).each_row { |row| rows << row.to_h }

      expect(rows).to eq([
        {"Type" => "Campaign", "Client Id" => "sdk-test", "Campaign" => "SDK Bulk Test"}
      ])
    end

    it "processes streamed CSV chunks" do
      rows = []
      chunks = csv.scan(/.{1,7}/m)

      described_class.new(chunks.each).each_row { |row| rows << row["Campaign"] }

      expect(rows).to eq(["SDK Bulk Test"])
    end

    it "processes quoted rows from a streamed ZIP" do
      content = "\uFEFF\"Report Name: SDK Report\"\r\n\"Report Time: Today\"\r\n\r\nTimePeriod,Clicks\r\n2026-08-02,1\r\n"
      zip = Zip::OutputStream.write_buffer do |archive|
        archive.put_next_entry("report.csv")
        archive.write(content)
      end
      rows = []

      described_class.new(zip.string.scan(/.{1,7}/m).each).each_row { |row| rows << row.to_h }

      expect(rows).to eq([{"TimePeriod" => "2026-08-02", "Clicks" => "1"}])
    end

    it "decompresses GZIP CSV" do
      buffer = StringIO.new(String.new(encoding: Encoding::BINARY))
      gzip = Zlib::GzipWriter.wrap(buffer)
      gzip.write(csv)
      gzip.close

      rows = described_class.new(buffer.string).to_csv

      expect(rows.first["Campaign"]).to eq("SDK Bulk Test")
    end
    it "reports the gunzip lifecycle event" do
      buffer = StringIO.new(String.new(encoding: Encoding::BINARY))
      gzip = Zlib::GzipWriter.wrap(buffer)
      gzip.write(csv)
      gzip.close
      events = []

      described_class.new(buffer.string, instrumentation: ->(event) { events << event }).to_csv

      gunzip = events.find { |event| event[:event] == :gunzip_finish }
      expect(gunzip).to include(
        compression: :gzip,
        input_bytes: buffer.string.bytesize,
        output_bytes: csv.bytesize,
        duration_ms: be_a(Float),
        success: true,
        error_class: nil
      )
    end

    it "decompresses ZIP CSV" do
      zip = Zip::OutputStream.write_buffer do |archive|
        archive.put_next_entry("campaign.csv")
        archive.write(csv)
      end

      rows = described_class.new(zip.string).to_csv

      expect(rows.first["Type"]).to eq("Campaign")
    end

    it "skips report metadata and exposes metric columns as row fields" do
      rows = described_class.new(report_csv).to_csv

      expect(rows.headers).to eq(["TimePeriod", "AccountId", "Impressions", "Clicks", "Spend"])
      expect(rows.length).to eq(1)
      expect(rows.first.to_h).to eq(
        "TimePeriod" => "2026-08-02",
        "AccountId" => "123456789",
        "Impressions" => "1",
        "Clicks" => "0",
        "Spend" => "0.00"
      )
    end

    it "detects quoted report metadata" do
      content = "\uFEFF\"Report Name: SDK Report\"\r\n\"Report Time: Today\"\r\n\r\nTimePeriod,Clicks\r\n2026-08-02,1\r\n"

      rows = described_class.new(content).to_csv

      expect(rows.headers).to eq(["TimePeriod", "Clicks"])
    end
  end
end
