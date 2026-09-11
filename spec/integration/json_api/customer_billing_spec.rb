# frozen_string_literal: true

RSpec.describe "JSON Customer Billing API" do
  include_context "json api with vcr"

  it "queries monthly spend through Customer Billing" do
    use_json_api_cassette("queries_monthly_spend_through_Customer_Billing") do
      response = api.customer_billing.get_account_monthly_spend(
        account_id: account_id,
        month_year: Date.new(Date.today.year, Date.today.month, 1).iso8601
      )

      expect(response).to include(:Amount)
    end
  end

  it "queries billing document information" do
    use_json_api_cassette("customer_billing_get_billing_documents_info") do
      response = api.customer_billing.get_billing_documents_info(
        account_ids: [account_id],
        start_date: (Date.today << 12).iso8601,
        end_date: Date.today.iso8601,
        return_invoice_number: false
      )

      expect(response).to include(:BillingDocumentsInfo)
    end
  end

  it "searches insertion orders for the account" do
    use_json_api_cassette("customer_billing_search_insertion_orders") do
      response = api.customer_billing.search_insertion_orders(
        predicates: [{field: "AccountId", operator: "Equals", value: account_id.to_s}],
        ordering: [{field: "Id", order: "Ascending"}],
        page_info: {index: 0, size: 25}
      )

      expect(response).to include(:InsertionOrders)
    end
  end
end
