RSpec.describe 'CampaignManagement service' do
  include_context 'use api'
  include_context 'manages campaigns'

  describe 'Campaign methods' do
    let(:a_campaign_list_hash) do
      {
        campaigns: {
          campaign: [a_campaign_hash],
        },
      }
    end

    let(:a_campaign_hash) do
      {
        bidding_scheme: { type: 'ManualCpc' },
        budget_type: 'DailyBudgetStandard',
        daily_budget: '10',
        description: 'This campaign was automatically generated in a test',
        forward_compatibility_map: '',
        id: a_kind_of(String),
        name: a_string_starting_with('Acceptance Test Campaign'),
        native_bid_adjustment: nil,
        status: 'Active',
        time_zone: 'BrusselsCopenhagenMadridParis',
        tracking_url_template: nil,
        url_custom_parameters: nil,
        campaign_type: 'SearchAndContent',
        settings: nil,
        budget_id: nil,
        languages: nil,
      }
    end

    subject(:get_campaigns_by_ids) do
      api.campaign_management.get_campaigns_by_ids(
        account_id: ACCOUNT_ID,
        campaign_ids: [{ long: campaign_id }]
      )
    end

    describe '#add_campaigns' do
      subject do
        api.campaign_management.add_campaigns(
          account_id: ACCOUNT_ID,
          campaigns: {
            campaign:
              {
                name: "Acceptance Test Campaign #{SecureRandom.hex}",
                daily_budget: 10,
                budget_type: 'DailyBudgetStandard',
                time_zone: 'BrusselsCopenhagenMadridParis',
                description: 'This campaign was automatically generated in a test',
              },
          }
        )
      end

      it 'returns campaign ids' do
        is_expected.to include(partial_errors: '',
                               campaign_ids: [a_kind_of(Integer)])
      end
    end

    describe '#get_campaigns_by_account_id' do
      before { example_campaign }

      subject do
        api.campaign_management.get_campaigns_by_account_id(
          account_id: ACCOUNT_ID
        )
      end

      it 'returns a list of campaigns' do
        is_expected.to include({
          campaigns: {
            campaign: a_collection_including(a_campaign_hash),
          }
        })
      end
    end

    describe '#get_campaigns_by_ids' do
      before { example_campaign }

      it 'returns a list of campaigns' do
        expect(get_campaigns_by_ids).to include(a_campaign_list_hash)
      end
    end

    describe '#update_campaigns' do
      subject do
        api.campaign_management.update_campaigns(
          account_id: ACCOUNT_ID,
          campaigns: {
            campaign: [
              id: campaign_id,
              name: 'Acceptance Test Campaign - updated',
            ],
          }
        )
      end
      let(:updated_campaign) { get_campaigns_by_ids[:campaigns][:campaign].first }

      it 'should return no errors' do
        is_expected.to eq(partial_errors: '')

        expect(updated_campaign).to include(name: 'Acceptance Test Campaign - updated')
      end
    end
  end
end
