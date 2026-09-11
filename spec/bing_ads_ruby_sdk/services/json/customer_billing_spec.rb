require "bing_ads_ruby_sdk/services/json/customer_billing"

RSpec.describe BingAdsRubySdk::Services::Json::CustomerBilling do
  let(:service) do
    described_class.new(
      base_url: "http://example.com/CustomerBilling/v13/",
      headers: {},
      auth_handler: double(:auth_handler, fetch_or_refresh: "token")
    )
  end
  let(:payload) { {fake_element: :fake_value} }

  describe "#get_billing_documents_info" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("BillingDocumentsInfo/Query", payload)
      service.get_billing_documents_info(payload)
    end
  end

  describe "#get_billing_documents" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("BillingDocuments/Query", payload)
      service.get_billing_documents(payload)
    end
  end

  describe "#add_insertion_order" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("InsertionOrder", payload)
      service.add_insertion_order(payload)
    end
  end

  describe "#update_insertion_order" do
    it "calls put with the correct operation and payload" do
      expect(service).to receive(:put).with("InsertionOrder", payload)
      service.update_insertion_order(payload)
    end
  end

  describe "#search_insertion_orders" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("InsertionOrders/Search", payload)
      service.search_insertion_orders(payload)
    end
  end

  describe "#get_account_monthly_spend" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("AccountMonthlySpend/Query", payload)
      service.get_account_monthly_spend(payload)
    end
  end
end
