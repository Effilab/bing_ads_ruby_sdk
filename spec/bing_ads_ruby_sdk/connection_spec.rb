RSpec.describe BingAdsRubySdk::Service do
  it "uses TLS 1.2" do
    url = "https://campaign.api.bingads.microsoft.com:443/Api/Advertiser/CampaignManagement/V11/CampaignManagementService.svc"
    connection = BingAdsRubySdk::Service.connection(url)

    options = connection.instance_variable_get(:@data)

    expect(options[:ssl_version].to_s).to eq("TLSv1_2")
    expect(options[:ciphers].to_s).to eq("TLSv1.2:!aNULL:!eNULL")
  end

  it "check TLS 1.2 from a service" do
    url = "https://www.howsmyssl.com/a/check"

    response = Excon.get(url)
    hash = JSON.parse(response.body)

    expect(hash["tls_version"]).to eq("TLS 1.2")
  end
end
