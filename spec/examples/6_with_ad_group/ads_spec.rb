require_relative '../examples'

RSpec.describe 'Ad methods' do
  include_context 'use api'

  def add_ads
    api.campaign_management.call(:add_ads,
      ad_group_id: Examples.ad_group_id,
      ads: [
        {
          expanded_text_ad: {
            ad_format_preference: 'All',
            domain: 'https://www.example.com/',
            final_urls: [string: 'http://www.contoso.com/'],
            path_1: 'subdirectory1',
            path_2: 'su§bdirectory2',
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

  def get_ads
    api.campaign_management.get_ads_by_ad_group_id(
      ad_group_id: Examples.ad_group_id,
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

  describe '#add_ads' do
    it 'returns created Ad ids' do
      expect(add_ads).to include(
        ad_ids: [a_kind_of(Integer)],
        partial_errors: ''
      )
    end
  end

  describe '#get_ads_by_ad_group_id' do
    before { add_ads }

    it 'returns a list of ads' do
      expect(get_ads).to include(
        {
          ad_format_preference: a_kind_of(String),
          device_preference: a_kind_of(String),
          editorial_status: a_kind_of(String),
          final_app_urls: nil,
          final_mobile_urls: nil,
          final_urls: a_kind_of(Hash),
          forward_compatibility_map: "",
          id: a_kind_of(String),
          status: a_kind_of(String),
          tracking_url_template: a_kind_of(String),
          type: "ExpandedText",
          url_custom_parameters: nil,
          domain: a_kind_of(String),
          path1: a_kind_of(String),
          path2: a_kind_of(String),
          text: a_kind_of(String),
          title_part1: a_kind_of(String),
          title_part2: a_kind_of(String)
        }
      )
    end
  end

  describe '#update_ads' do
    before { add_ads }

    it 'updates the Ad' do
      expect(api.campaign_management.call(:update_ads,
        ad_group_id: Examples.ad_group_id,
        ads: {
          expanded_text_ad: [{
            id: get_ads.first[:id],
            text: "Ad text goes here - #{random}"
          }],
        }
      )).to eq(partial_errors: '')

      expect(get_ads.first).to include( text: "Ad text goes here - #{random}")
    end
  end

  describe 'test_delete_ads' do
    let(:ad_id) { add_ads[:ad_ids].first }

    it 'returns no errors' do
      expect(api.campaign_management.call(:delete_ads,
        ad_group_id: Examples.ad_group_id,
        ad_ids: [long: ad_id]
      )).to eq(partial_errors: '')

      expect(get_ads.map{|h| h[:id]}).not_to include ad_id.to_s
    end
  end
end
