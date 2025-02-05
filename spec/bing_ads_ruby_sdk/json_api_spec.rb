require "bing_ads_ruby_sdk/json_api"

RSpec.describe BingAdsRubySdk::JsonApi do
  let(:headers) do
    {
      "DeveloperToken" => "token",
      "ClientId" => "id",
      "ClientSecret" => "secret",
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end
  let(:store) { double(:store) }
  let(:auth_handler) { double(:auth_handler) }

  subject do
    described_class.new(
      developer_token: "token",
      client_id: "id",
      client_secret: "secret",
      oauth_store: store
    )
  end

  def expect_auth_handler
    expect(BingAdsRubySdk::OAuth2::AuthorizationHandler)
      .to receive(:new)
      .with(
        developer_token: "token",
        client_id: "id",
        client_secret: "secret",
        store: store
      )
      .and_return(auth_handler)
  end

  describe "#initialize" do
    context "with an invalid version" do
      it "raises an error" do
        expect do
          described_class.new(
            developer_token: "token",
            client_id: "id",
            client_secret: "secret",
            oauth_store: store,
            version: :invalid
          )
        end.to raise_error(ArgumentError, "Invalid version format")
      end
    end
  end

  describe "#campaign_management" do
    let(:service) { double(:service) }

    before do
      expect_auth_handler
      expect(BingAdsRubySdk::Services::Json::CampaignManagement)
        .to receive(:new)
        .with(base_url: url, headers: headers, auth_handler: auth_handler)
        .and_return(service)
    end

    context "with production environment" do
      let(:url) { "https://campaign.api.bingads.microsoft.com/CampaignManagement/v13/" }

      it "points to the production URL" do
        expect(subject.campaign_management).to eq(service)
      end
    end

    context "with sandbox environment" do
      let(:url) { "https://campaign.api.sandbox.bingads.microsoft.com/CampaignManagement/v13/" }

      subject do
        described_class.new(
          developer_token: "token",
          client_id: "id",
          oauth_store: store,
          client_secret: "secret",
          environment: :sandbox
        )
      end

      it "points to the sandbox URL" do
        expect(subject.campaign_management).to eq(service)
      end
    end

    context "with custom version" do
      let(:url) { "https://campaign.api.bingads.microsoft.com/CampaignManagement/v11/" }
      let(:version) { :v11 }
      subject do
        described_class.new(
          developer_token: "token",
          client_id: "id",
          oauth_store: store,
          client_secret: "secret",
          version: version
        )
      end

      it "points to the custom version URL" do
        expect(subject.campaign_management).to eq(service)
      end
    end
  end
end
