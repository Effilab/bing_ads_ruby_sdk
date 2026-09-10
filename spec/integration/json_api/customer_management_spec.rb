# frozen_string_literal: true

RSpec.describe "JSON Customer Management API" do
  include_context "json api with vcr"

  it "queries account details through Customer Management" do
    use_json_api_cassette("queries_account_details_through_Customer_Management") do
      response = api.customer_management.get_account(account_id: account_id)

      expect(response).to include(:Account)
    end
  end

  it "finds accounts or customers" do
    use_json_api_cassette("customer_management_find_accounts_or_customers_info") do
      response = api.customer_management.find_accounts_or_customers_info(
        predicate: {
          field: "AccountId",
          operator: "Equals",
          value: account_id.to_s
        }
      )

      expect(response[:AccountInfoWithCustomerData]).not_to be_empty
    end
  end

  it "finds accounts" do
    use_json_api_cassette("customer_management_find_accounts") do
      response = api.customer_management.find_accounts(
        customer_id: customer_id,
        account_filter: "",
        top_n: 5
      )

      expect(response[:AccountsInfo]).not_to be_empty
    end
  end

  it "gets customer details" do
    use_json_api_cassette("customer_management_get_customer") do
      response = api.customer_management.get_customer(customer_id: customer_id)

      expect(response[:Customer]).to include(Id: customer_id.to_s)
    end
  end

  it "gets customer information" do
    use_json_api_cassette("customer_management_get_customers_info") do
      response = api.customer_management.get_customers_info(
        customer_name_filter: "",
        top_n: 5
      )

      expect(response[:CustomersInfo]).not_to be_empty
    end
  end

  it "updates an account with its current values" do
    use_json_api_cassette("customer_management_update_account") do
      account = api.customer_management.get_account(account_id: account_id).fetch(:Account)
      account = BingAdsRubySdk::Postprocessors::Snakize.new(JSON.parse(account.to_json)).call
      response = api.customer_management.update_account(account: account)

      expect(response).to include(:LastModifiedTime)
    end
  end

  it "updates a customer with its current values" do
    use_json_api_cassette("customer_management_update_customer") do
      customer = api.customer_management.get_customer(customer_id: customer_id).fetch(:Customer)
      customer = BingAdsRubySdk::Postprocessors::Snakize.new(JSON.parse(customer.to_json)).call
      response = api.customer_management.update_customer(customer: customer)

      expect(response).to include(:LastModifiedTime)
    end
  end
end
