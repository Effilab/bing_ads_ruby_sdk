# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'
  include_context 'manages campaigns'

  describe 'Keyword methods' do
    let(:ad_group_id) { add_ad_group[:ad_group_ids].first }
    let(:keyword_id) { add_keywords[:keyword_ids].first }

    let(:a_keyword) do
      {
        keywords: {
          keyword: [
            {
              bid: {
                amount: "0.05",
              },
              bidding_scheme: {
                type: "InheritFromParent",
              },
              destination_url: "",
              editorial_status: "Active",
              final_app_urls: nil,
              final_mobile_urls: nil,
              final_urls: nil,
              forward_compatibility_map: "",
              id: a_kind_of(String),
              match_type: "Exact",
              param1: "",
              param2: "",
              param3: "",
              status: "Active",
              text: "AcceptanceTestKeyword",
              tracking_url_template: nil,
              url_custom_parameters: nil,
            },
          ],
        },
      }
    end

    subject(:add_ad_group) do
      api.campaign_management.add_ad_groups(
        campaign_id: campaign_id,
        ad_groups: { ad_group: {
          name: 'AcceptanceTestAdGroup',
          ad_distribution: 'Search Content',
          language: 'French',
        } }
      )
    end

    subject(:add_keywords) do
      api.campaign_management.add_keywords(
        ad_group_id: ad_group_id,
        keywords: { keyword: {
          bid: { amount: 0.05 },
          match_type: 'Exact',
          text: 'AcceptanceTestKeyword',
        } }
      )
    end

    describe '#add_keywords' do
      it 'returns created Keyword ids' do
        expect(add_keywords).to include(keyword_ids: [a_kind_of(Integer)],
                                        partial_errors: '')
      end
    end

    describe '#get_keywords_by_ad_group_id' do
      before { add_keywords }

      subject do
        api.campaign_management.get_keywords_by_ad_group_id(
          ad_group_id: ad_group_id
        )
      end

      it 'returns a list of keywords' do
        is_expected.to include(a_keyword)
      end
    end

    describe '#get_keywords_by_editorial_status' do
      before { add_keywords }

      subject do
        api.campaign_management.get_keywords_by_editorial_status(
          ad_group_id: ad_group_id,
          editorial_status: 'Active'
        )
      end

      it 'returns a list of Keywords' do
        is_expected.to include(a_keyword)
      end
    end

    describe '#get_keywords_by_ids' do
      before { add_keywords }

      subject do
        api.campaign_management.get_keywords_by_ids(
          ad_group_id: ad_group_id,
          keyword_ids: [{ long: keyword_id }]
        )
      end
      it 'returns a list of Keywords' do
        is_expected.to include(a_keyword)
      end
    end

    describe '#update_keywords' do
      subject do
        api.campaign_management.update_keywords(
          ad_group_id: ad_group_id,
          keywords: { keyword: [
            id: keyword_id,
            bid: { amount: 0.50 },
          ] }
        )
      end

      it 'updates the keyword' do
        is_expected.to eq(partial_errors: '')
      end
    end

    describe '#delete_keywords' do
      subject do
        api.campaign_management.delete_keywords(
          ad_group_id: ad_group_id,
          keyword_ids: [{ long: keyword_id }]
        )
      end

      it 'returns no errors' do
        is_expected.to eq(partial_errors: '')
      end
    end
  end
end
