# frozen_string_literal: true

require "bing_ads_ruby_sdk/services/json/base"

module BingAdsRubySdk
  module Services
    module Json
      class CustomerManagement < Base
        def get_account(payload)
          post("Account/Query", payload)
        end

        def find_accounts(payload)
          post("Accounts/Find", payload)
        end

        def get_customer(payload)
          post("Customer/Query", payload)
        end

        def get_customers_info(payload)
          post("CustomersInfo/Query", payload)
        end

        def find_accounts_or_customers_info(payload)
          post("AccountsOrCustomersInfo/Find", payload)
        end

        def update_account(payload)
          put("Account", payload)
        end

        def update_customer(payload)
          put("Customer", payload)
        end

        def signup_customer(payload)
          post("Customer/Signup", payload)
        end
      end
    end
  end
end
