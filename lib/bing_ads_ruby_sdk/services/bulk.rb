module BingAdsRubySdk
  module Services
    class Bulk < Base

      def download_campaigns_by_account_ids(message)
        call_wrapper(__method__, message)
      end

      def get_bulk_download_status(message)
        call_wrapper(__method__, message)
      end

      def get_bulk_upload_url(message)
        call_wrapper(__method__, message)
      end

      def get_bulk_upload_status(message)
        call_wrapper(__method__, message)
      end

      def self.service
        :bulk
      end
    end
  end
end