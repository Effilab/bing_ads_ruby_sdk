require_relative '../example_helper'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'
  include_context 'manages campaigns'

  describe 'AdGroup methods' do
    subject(:add_ad_group) do
      api.campaign_management.add_ad_groups(
        campaign_id: campaign_id,
        ad_groups: {
          ad_group: {
            name: 'AcceptanceTestAdGroup',
            language: 'French',
            start_date: {
              day: '1',
              month: '1',
              year: '2049',
            },
            # MSDN documentation shows that setting this date
            # to a value >= 2-Jan-2050 sets it to nil
            end_date: {
              day: '1',
              month: '2',
              year: '2049',
            },
          },
        }
      )
    end

    let(:ad_group_ids) { add_ad_group[:ad_group_ids] }
    let(:ad_group_id) { ad_group_ids.first }

    let(:ad_group_record_list) do
      {
        ad_groups: {
          ad_group:
            [
              {
                ad_rotation: nil,
                audience_ads_bid_adjustment: nil,
                bidding_scheme: a_collection_including(type: "InheritFromParent"),
                cpc_bid: { amount: "0.05" },
                forward_compatibility_map: "",
                id: a_kind_of(String),
                language: "French",
                name: "AcceptanceTestAdGroup",
                network: "OwnedAndOperatedAndSyndicatedSearch",
                settings: nil,
                start_date: {
                  day: '1',
                  month: '1',
                  year: '2049',
                },
                end_date: {
                  day: '1',
                  month: '2',
                  year: '2049',
                },
                status: "Paused",
                tracking_url_template: nil,
                url_custom_parameters: nil,
              },
            ],
        },
      }
    end

    describe '#add_ad_groups' do
      it 'returns created AdGroup ids' do
        expect(add_ad_group).to include(
          ad_group_ids: [a_kind_of(Integer)],
          partial_errors: ''
        )
      end
    end

    describe '#get_ad_groups_by_ids' do
      subject do
        api.campaign_management.get_ad_groups_by_ids(
          campaign_id: campaign_id,
          ad_group_ids: ad_group_ids.map { |long| { long: long } }
        )
      end

      it 'returns AdGroups' do
        is_expected.to include(ad_group_record_list)
      end
    end

    describe '#get_ad_groups_by_campaign_id' do
      subject do
        api.campaign_management.get_ad_groups_by_campaign_id(
          campaign_id: campaign_id
        )
      end

      context 'when there are no campaigns' do
        it 'returns an empty list' do
          is_expected.to eq(ad_groups: '')
        end
      end

      context 'when there are campaigns' do
        before { add_ad_group }

        it 'returns AdGroups' do
          is_expected.to include(ad_group_record_list)
        end
      end
    end

    describe '#update_ad_groups' do
      subject do
        api.campaign_management.update_ad_groups(
          campaign_id: campaign_id,
          ad_groups: {
            ad_group: [
              id: ad_group_id,
            ],
          }
        )
      end

      it 'updates the ad' do
        is_expected.to eq(partial_errors: '', inherited_bid_strategy_types: nil)
      end
    end

    describe '#delete_ad_groups' do
      subject do
        api.campaign_management.delete_ad_groups(
          campaign_id: campaign_id,
          ad_group_ids: { long: ad_group_id }
        )
      end
      it 'returns no errors' do
        is_expected.to eq(partial_errors: '')
      end
    end
  end
end
