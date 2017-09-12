# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'
  include_context 'manages campaigns'

  describe 'Ad methods' do
    let(:ad_group_id) { add_ad_group[:ad_group_ids].first }
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

    subject(:add_ads) do
      api.campaign_management.add_ads(
        ad_group_id: ad_group_id,
        ads: [
          {
            expanded_text_ad: {
              ad_format_preference: 'All',
              display_url: 'https://www.example.com/',
              final_urls: [string: 'http://www.contoso.com/'],
              path_1: 'subdirectory1',
              path_2: 'subdirectory2',
              text: 'Ad text goes here',
              title_part_1: 'Title goes here',
              title_part_2: 'Title 2 goes here',
              status: 'Paused',
              tracking_url_template: '{lpurl}',
            },
          },
        ]
      )
    end

    # This method is used when we don't want RSpec to memoize
    # the call. It will always make a request to the API
    def get_ads_without_memo
      api.campaign_management.get_ads_by_ad_group_id(
        ad_group_id: ad_group_id,
        ad_types: [
          { ad_type: 'Text' },
          { ad_type: 'Image' },
          { ad_type: 'Product' },
          { ad_type: 'AppInstall' },
          { ad_type: 'ExpandedText' },
          { ad_type: 'DynamicSearch' },
        ]
      )
    end

    subject(:get_ads) do
      get_ads_without_memo
    end

    describe '#add_ads' do
      it 'returns created Ad ids' do
        expect(add_ads).to include(ad_ids: [a_kind_of(Integer)],
                                   partial_errors: '')
      end
    end

    describe '#get_ads_by_ad_group_id' do
      before { add_ads }

      it 'returns a list of ads' do
        expect(get_ads).to include(
          ads: {
            ad: [
              {
                ad_format_preference: "All",
                device_preference: "0",
                editorial_status: "Active",
                final_app_urls: nil,
                final_mobile_urls: nil,
                final_urls: { string: ["http://www.contoso.com/"] },
                forward_compatibility_map: "",
                id: a_kind_of(String),
                status: "Paused",
                tracking_url_template: "{lpurl}",
                type: "ExpandedText",
                url_custom_parameters: nil,
                display_url: "www.contoso.com",
                path1: "subdirectory1",
                path2: "subdirectory2",
                text: "Ad text goes here",
                title_part1: "Title goes here",
                title_part2: "Title 2 goes here",
              },
            ],
          }
        )
      end
    end

    describe '#update_ads' do
      let(:original_ad) do
        get_ads[:ads][:ad].first
      end
      let(:changed_ad) do
        original_ad.merge(
          path1: 'new_path',
          final_urls: [string: original_ad[:final_urls][:string].first]
        ).tap do |ad|
          ad.delete(:url_custom_parameters)
          ad.delete(:editorial_status)
        end
      end
      let(:first_updated_ad) { get_ads_without_memo[:ads][:ad].first }

      before { add_ads }
      subject do
        api.campaign_management.update_ads(
          ad_group_id: ad_group_id,
          ads: {
            expanded_text_ad: [changed_ad],
          }
        )
      end

      it 'updates the Ad' do
        is_expected.to eq(partial_errors: '')

        expect(first_updated_ad).to include(path1: 'new_path')
      end
    end

    describe 'test_delete_ads' do
      let(:ad_id) { add_ads[:ad_ids].first }

      subject do
        api.campaign_management.delete_ads(
          ad_group_id: ad_group_id,
          ad_ids: [long: ad_id]
        )
      end

      it 'returns no errors' do
        is_expected.to eq(partial_errors: '')
      end
    end
  end
end
