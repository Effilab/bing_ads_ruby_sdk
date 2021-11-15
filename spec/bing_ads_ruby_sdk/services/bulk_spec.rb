RSpec.describe BingAdsRubySdk::Services::Bulk do
  let(:service_name) { described_class.service }
  let(:soap_client) { SpecHelpers.soap_client(service_name) }
  let(:expected_xml) { SpecHelpers.request_xml_for(service_name, action, filename) }
  let(:mocked_response) { SpecHelpers.response_xml_for(service_name, action, filename) }

  let(:service) { described_class.new(soap_client) }

  before do
    expect(BingAdsRubySdk::HttpClient).to receive(:post) do |req|
      expect(Nokogiri::XML(req.content).to_xml).to eq expected_xml.to_xml
      mocked_response
    end
  end

  describe "download_campaigns_by_account_ids" do
    let(:action) { "download_campaigns_by_account_ids" }
    let(:filename) { "standard" }

    it "returns expected result" do
      expect(
        service.download_campaigns_by_account_ids(
          account_ids: [{long: 150168726}],
          data_scope: "EntityData",
          download_file_type: "Csv",
          compression_type: "Zip",
          download_entities: [
            {download_entity: "Campaigns"}
          ],
          format_version: "6.0"
        )
      ).to eq({
        download_request_id: "618504973441"
      })
    end
  end

  describe "get_bulk_download_status" do
    let(:action) { "get_bulk_download_status" }
    let(:filename) { "standard" }

    it "returns expected result" do
      expect(
        service.get_bulk_download_status(request_id: 618504973441)
      ).to include(
        request_status: "Completed",
        result_file_url: "cool_url"
      )
    end
  end
end
