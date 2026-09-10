# frozen_string_literal: true

RSpec.describe "JSON Bulk API" do
  include_context "json api with vcr"

  it "requests a Bulk upload URL" do
    use_json_api_cassette("requests_a_Bulk_upload_URL") do
      response = api.bulk.get_bulk_upload_url(
        account_id: account_id,
        compress_upload: false,
        account_upload_scope: "Customer",
        entities: ["Campaigns"]
      )

      expect(response).to include(:RequestId, :UploadUrl)
    end
  end

  it "polls the Bulk upload URL request" do
    use_json_api_cassette("bulk_get_bulk_upload_status") do
      upload = api.bulk.get_bulk_upload_url(
        account_id: account_id,
        compress_upload: false,
        account_upload_scope: "Customer",
        entities: ["Campaigns"]
      )
      response = api.bulk.get_bulk_upload_status(request_id: upload.fetch(:RequestId))

      expect(response).to include(:RequestStatus)
    end
  end

  it "downloads campaigns through Bulk" do
    use_json_api_cassette("bulk_download_campaigns_by_account_ids") do
      response = api.bulk.download_campaigns_by_account_ids(
        account_ids: [account_id],
        compression_type: "Zip",
        data_scope: "EntityData",
        download_entities: ["Campaigns"],
        download_file_type: "Csv",
        format_version: "6.0"
      )

      expect(response).to include(:DownloadRequestId)
    end
  end
end
