# frozen_string_literal: true

require_relative '../examples'

RSpec.describe 'AdGroup methods' do
  include_context 'use api'

  let(:ad_group_record) do
    a_hash_including(
      ad_rotation: nil,
      bidding_scheme: a_kind_of(Hash),
      cpc_bid: a_kind_of(Hash),
      id: a_kind_of(String),
      language: a_kind_of(String),
      name: a_kind_of(String),
      network: a_kind_of(String),
      settings: nil,
      start_date: {
        day: '1',
        month: '1',
        year: '2049'
      },
      end_date: {
        day: '1',
        month: '2',
        year: '2049'
      },
      status: a_kind_of(String),
      tracking_url_template: nil,
      url_custom_parameters: nil
    )
  end

  describe '#get_ad_groups_by_ids' do
    it 'returns AdGroups' do
      expect(api.campaign_management.get_ad_groups_by_ids(
               campaign_id: Examples.campaign_id,
               ad_group_ids: [{ long: Examples.ad_group_id }]
             )).to include(ad_group_record)
    end
  end

  describe '#get_ad_groups_by_campaign_id' do
    it 'returns AdGroups' do
      expect(api.campaign_management.get_ad_groups_by_campaign_id(
               campaign_id: Examples.campaign_id
             )).to include(ad_group_record)
    end
  end

  describe '#update_ad_groups' do
    it 'updates the ad' do
      expect(api.campaign_management.call(:update_ad_groups,
                                          campaign_id: Examples.campaign_id,
                                          ad_groups: {
                                            ad_group: [{
                                              id: Examples.ad_group_id,
                                              name: "AcceptanceTestAdGroup - #{random}"
                                            }]
                                          })).to eq(partial_errors: '', inherited_bid_strategy_types: nil)

      ad_group = api.campaign_management.get_ad_groups_by_ids(
        campaign_id: Examples.campaign_id,
        ad_group_ids: [{ long: Examples.ad_group_id }]
      ).first

      expect(ad_group).to include(
        name: "AcceptanceTestAdGroup - #{random}"
      )
    end
  end
end
