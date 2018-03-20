RSpec.describe BingAdsRubySdk::Service do
  let(:connection) { BingAdsRubySdk::Service.connection(url) }

  context "when connecting to Bing" do
    let(:url) { "https://campaign.api.bingads.microsoft.com:443/Api/Advertiser/CampaignManagement/V11/CampaignManagementService.svc" }

    it "uses TLS 1.2" do
      options = connection.instance_variable_get(:@data)

      expect(options[:ssl_version].to_s).to eq("TLSv1_2")
      expect(options[:ciphers].to_s).to eq("TLSv1.2:!aNULL:!eNULL")
    end
  end

  context "when connecting to a test service" do
    let(:url) { "https://www.howsmyssl.com/a/check" }

    it "checks TLS 1.2 from a service" do
      path = URI(url).path
      response = connection.get(path: path)
      hash = JSON.parse(response.body)
      expect(hash["tls_version"]).to eq("TLS 1.2")
    end
  end
end
