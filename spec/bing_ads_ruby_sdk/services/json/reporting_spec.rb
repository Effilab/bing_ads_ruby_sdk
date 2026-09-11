require "bing_ads_ruby_sdk/services/json/reporting"

RSpec.describe BingAdsRubySdk::Services::Json::Reporting do
  let(:service) do
    described_class.new(
      base_url: "http://example.com/Reporting/v13/",
      headers: {},
      auth_handler: double(:auth_handler, fetch_or_refresh: "token")
    )
  end
  let(:payload) { {fake_element: :fake_value} }

  describe "#submit_generate_report" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("GenerateReport/Submit", payload)
      service.submit_generate_report(payload)
    end
  end

  describe "#poll_generate_report" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("GenerateReport/Poll", payload)
      service.poll_generate_report(payload)
    end
  end

  describe "#download_file" do
    it "downloads the report file" do
      expect(BingAdsRubySdk::HttpClient)
        .to receive(:get)
        .with("https://download.example.com/report.csv")
        .and_return("report content")

      expect(service.download_file(url: "https://download.example.com/report.csv"))
        .to eq("report content")
    end

    it "streams the report file when requested" do
      chunks = ["first", "second"].each
      expect(BingAdsRubySdk::HttpClient)
        .to receive(:get)
        .with("https://download.example.com/report.csv", stream: true)
        .and_return(chunks)

      expect(service.download_file(url: "https://download.example.com/report.csv", stream: true).to_a)
        .to eq(["first", "second"])
    end
  end
end
