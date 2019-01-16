module BingAdsRubySdk
  module Services
    class CustomerManagement < Base

      def get_account(message)
        call_wrapper(__method__, message)
      end

      def update_account(message)
        call_wrapper(__method__, message)
      end

      def find_accounts_or_customers_info(message)
        call_wrapper(__method__, message, :account_info_with_customer_data, :account_info_with_customer_data)
      end

      def signup_customer(message)
        call_wrapper(__method__, message)
      end

      def self.service
        :customer_management
      end
    end
  end
end