require "bing_ads_ruby_sdk/services/json/bulk"

RSpec.describe BingAdsRubySdk::Services::Json::Bulk do
  let(:service) do
    described_class.new(
      base_url: "http://example.com/Bulk/v13/",
      headers: {},
      auth_handler: double(:auth_handler, fetch_or_refresh: "token")
    )
  end
  let(:payload) { {fake_element: :fake_value} }

  describe "#download_campaigns_by_account_ids" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("Campaigns/DownloadByAccountIds", payload)
      service.download_campaigns_by_account_ids(payload)
    end
  end

  describe "#get_bulk_download_status" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("BulkDownloadStatus/Query", payload)
      service.get_bulk_download_status(payload)
    end
  end

  describe "#get_bulk_upload_url" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("BulkUploadUrl/Query", payload)
      service.get_bulk_upload_url(payload)
    end
  end

  describe "#get_bulk_upload_status" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("BulkUploadStatus/Query", payload)
      service.get_bulk_upload_status(payload)
    end
  end

  describe "#upload_file" do
    it "uploads the file with Microsoft authentication headers" do
      expect(BingAdsRubySdk::HttpClient).to receive(:post_multipart).with(
        url: "https://upload.example.com/file",
        headers: {"AuthenticationToken" => "token"},
        content: "bulk content",
        filename: "bulk.csv"
      ).and_return("accepted")

      expect(
        service.upload_file(
          upload_url: "https://upload.example.com/file",
          content: "bulk content",
          filename: "bulk.csv"
        )
      ).to eq("accepted")
    end
  end

  describe "#download_file" do
    it "downloads the result file" do
      expect(BingAdsRubySdk::HttpClient)
        .to receive(:get)
        .with("https://download.example.com/result.zip")
        .and_return("compressed content")

      expect(service.download_file(url: "https://download.example.com/result.zip"))
        .to eq("compressed content")
    end

    it "streams the result file when requested" do
      chunks = ["first", "second"].each
      expect(BingAdsRubySdk::HttpClient)
        .to receive(:get)
        .with("https://download.example.com/result.zip", stream: true)
        .and_return(chunks)

      expect(service.download_file(url: "https://download.example.com/result.zip", stream: true).to_a)
        .to eq(["first", "second"])
    end
  end
end
