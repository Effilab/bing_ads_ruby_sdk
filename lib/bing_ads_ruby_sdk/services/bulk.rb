# frozen_string_literal: true

module BingAdsRubySdk
  module Services
    class Bulk < Base
      def download_campaigns_by_account_ids(message)
        call(__method__, message)
      end

      def get_bulk_download_status(message)
        call(__method__, message)
      end

      def get_bulk_upload_url(message)
        call(__method__, message)
      end

      def get_bulk_upload_status(message)
        call(__method__, message)
      end

      def self.service
        :bulk
      end
    end
  end
end
