require 'fixtures'
require 'bing_ads_ruby_sdk/wsdl_parser'

module BingAdsRubySdk
  RSpec.describe WSDLParser do
    let(:legacy_client) do
      LolSoap::Client.new(Fixtures.wsdl_file)
    end
    let(:client) { Fixtures.lol_campaign_management }

    describe 'client' do
      it { expect(client.wsdl.class).to be legacy_client.wsdl.class }
      it 'adds abstract types' do
        expect(
          legacy_client.wsdl.types['ArrayOfCampaignCriterion'].elements.keys
        ).to eq %w[CampaignCriterion]

        expect(
          client.wsdl.types['ArrayOfCampaignCriterion'].elements.keys
        ).to eq %w[CampaignCriterion BiddableCampaignCriterion NegativeCampaignCriterion]
      end
    end
  end
end
