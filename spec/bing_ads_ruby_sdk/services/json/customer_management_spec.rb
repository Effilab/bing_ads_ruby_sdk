require "bing_ads_ruby_sdk/services/json/customer_management"

RSpec.describe BingAdsRubySdk::Services::Json::CustomerManagement do
  let(:service) do
    described_class.new(
      base_url: "http://example.com/CustomerManagement/v13/",
      headers: {},
      auth_handler: double(:auth_handler, fetch_or_refresh: "token")
    )
  end
  let(:payload) { {fake_element: :fake_value} }

  describe "#get_account" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("Account/Query", payload)
      service.get_account(payload)
    end
  end

  describe "#find_accounts_or_customers_info" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("AccountsOrCustomersInfo/Find", payload)
      service.find_accounts_or_customers_info(payload)
    end
  end

  describe "#find_accounts" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("Accounts/Find", payload)
      service.find_accounts(payload)
    end
  end

  describe "#get_customer" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("Customer/Query", payload)
      service.get_customer(payload)
    end
  end

  describe "#get_customers_info" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("CustomersInfo/Query", payload)
      service.get_customers_info(payload)
    end
  end

  describe "#update_customer" do
    it "calls put with the correct operation and payload" do
      expect(service).to receive(:put).with("Customer", payload)
      service.update_customer(payload)
    end
  end

  describe "#update_account" do
    it "calls put with the correct operation and payload" do
      expect(service).to receive(:put).with("Account", payload)
      service.update_account(payload)
    end
  end

  describe "#signup_customer" do
    it "calls post with the correct operation and payload" do
      expect(service).to receive(:post).with("Customer/Signup", payload)
      service.signup_customer(payload)
    end
  end
end
