RSpec.describe BingAdsRubySdk::Services::CustomerManagement do
  let(:service_name) { described_class.service }
  let(:soap_client) { SpecHelpers.soap_client(service_name) }
  let(:expected_xml) { SpecHelpers.request_xml_for(service_name, action, filename) }
  let(:mocked_response) { SpecHelpers.response_xml_for(service_name, action, filename) }

  let(:service) { described_class.new(soap_client) }

  before do
    expect(BingAdsRubySdk::HttpClient).to receive(:post) do |req|
      expect(Nokogiri::XML(req.content).to_xml).to eq expected_xml.to_xml
      mocked_response
    end
  end

  describe "signup_customer" do
    let(:action) { "signup_customer" }
    let(:filename) { "standard" }

    it "returns expected result" do
      expect(
        service.signup_customer(
          parent_customer_id: 9876,
          customer: {
            industry: "NA",
            market_country: "FR",
            market_language: "French",
            name: "sdk customer",
            customer_address: {
              city: "Nice",
              country_code: "FR",
              line1: "127 bd risso",
              postal_code: "06000"
            }
          },
          # Note that the structure of this type is slightly different to other types, in accord with the Bing WSDL
          account: {
            "@type" => "AdvertiserAccount",
            :currency_code => "EUR",
            :name => "SDK account"
          }
        )
      ).to include(
        customer_id: "1234",
        account_id: "5678"
      )
    end
  end

  describe "get_account" do
    let(:action) { "get_account" }
    let(:filename) { "standard" }

    it "returns expected result" do
      expect(
        service.get_account(account_id: 5678)
      ).to include(
        account: a_hash_including(id: "5678", name: "SDKTEST")
      )
    end
  end

  describe "update_account" do
    let(:action) { "update_account" }
    let(:filename) { "standard" }

    it "returns expected result" do
      expect(
        service.update_account(
          account: {
            "@type" => "AdvertiserAccount",
            :id => 5678,
            :time_stamp => "AAAAAE496a4=",
            :currency_code => "EUR",
            :name => "SDKTEST updated"
          }
        )
      ).to eq(
        last_modified_time: "2019-01-18T13:16:38.827"
      )
    end
  end

  describe "find_accounts_or_customers_info" do
    let(:action) { "find_accounts_or_customers_info" }
    let(:filename) { "standard" }

    it "returns expected result" do
      expect(
        service.find_accounts_or_customers_info(filter: "SDKTEST", top_n: 1)
      ).to contain_exactly(
        a_hash_including(customer_name: "SDKTEST updated", account_id: "5678")
      )
    end
  end
end
