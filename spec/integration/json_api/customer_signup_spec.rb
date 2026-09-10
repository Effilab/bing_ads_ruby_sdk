# frozen_string_literal: true

RSpec.describe "JSON Customer Signup API" do
  include_context "json api with vcr"

  it "creates one customer and account" do
    use_json_api_cassette("customer_signup_creates_one_customer_and_account") do
      suffix = SecureRandom.hex(6)
      response = api.customer_management.signup_customer(
        customer: {
          customer_address: {
            city: "Paris",
            postal_code: "75001",
            line1: "1 rue de Rivoli",
            country_code: "FR"
          },
          industry: "NA",
          market_country: "FR",
          market_language: "French",
          name: "SDK VCR Customer #{suffix}"
        },
        account: {
          name: "SDK VCR Account #{suffix}",
          currency_code: "EUR",
          payment_method_id: nil
        },
        parent_customer_id: customer_id
      )

      expect(response).to include(
        CustomerId: a_kind_of(String),
        CustomerNumber: a_kind_of(String),
        AccountId: a_kind_of(String),
        AccountNumber: a_kind_of(String),
        CreateTime: a_kind_of(String)
      )
    end
  end
end
