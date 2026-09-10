require "bing_ads_ruby_sdk/bulk_file_builder"

RSpec.describe BingAdsRubySdk::BulkFileBuilder do
  describe "#to_s" do
    it "builds a versioned CSV with typed records" do
      builder = described_class.new
      builder.add_record(
        "Campaign",
        {
          "Status" => "Paused",
          "Campaign" => "SDK Bulk Test",
          "Campaign Type" => "Search"
        }
      )

      csv = builder.to_s

      expect(csv).to start_with("\uFEFF")
      expect(csv).to include("Type,Name,Status,Campaign,Campaign Type")
      expect(csv).to include("Format Version,6.0")
      expect(csv).to include("Campaign,,Paused,SDK Bulk Test,Search")
    end

    it "supports tab-delimited output" do
      builder = described_class.new(delimiter: "\t")
      builder.add_record("Campaign", {"Campaign" => "SDK Bulk Test"})

      expect(builder.to_s).to include("Type\tName\tCampaign")
    end
  end
end
