# frozen_string_literal: true

require "bing_ads_ruby_sdk/services/json/base"

module BingAdsRubySdk
  module Services
    module Json
      class CustomerBilling < Base
        def get_billing_documents_info(payload)
          post("BillingDocumentsInfo/Query", payload)
        end

        def get_billing_documents(payload)
          post("BillingDocuments/Query", payload)
        end

        def add_insertion_order(payload)
          post("InsertionOrder", payload)
        end

        def update_insertion_order(payload)
          put("InsertionOrder", payload)
        end

        def search_insertion_orders(payload)
          post("InsertionOrders/Search", payload)
        end

        def get_account_monthly_spend(payload)
          post("AccountMonthlySpend/Query", payload)
        end
      end
    end
  end
end
