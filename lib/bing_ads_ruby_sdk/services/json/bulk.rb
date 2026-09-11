# frozen_string_literal: true

require "bing_ads_ruby_sdk/services/json/base"

module BingAdsRubySdk
  module Services
    module Json
      class Bulk < Base
        def upload_file(upload_url:, content:, filename: "bulk.csv")
          client.post_multipart(
            url: upload_url,
            headers: headers.merge("AuthenticationToken" => auth_handler.fetch_or_refresh),
            content: content,
            filename: filename
          )
        end

        def download_file(url:, stream: false)
          stream ? client.get(url, stream: true) : client.get(url)
        end

        def download_campaigns_by_account_ids(payload)
          post("Campaigns/DownloadByAccountIds", payload)
        end

        def get_bulk_download_status(payload)
          post("BulkDownloadStatus/Query", payload)
        end

        def get_bulk_upload_url(payload)
          post("BulkUploadUrl/Query", payload)
        end

        def get_bulk_upload_status(payload)
          post("BulkUploadStatus/Query", payload)
        end
      end
    end
  end
end
