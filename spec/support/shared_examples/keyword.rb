# frozen_string_literal: true

RSpec.shared_context 'manages keywords' do
  include_context 'manages adgroups'

  def example_keywords
    @example_keywords ||= create_keywords
  end

  def keyword_ids
    example_keywords[:keyword_ids]
  end

  def create_keywords
    clean_keywords

    api.campaign_management.add_keywords(
      ad_group_id: ad_group_id,
      keywords: { keyword: {
        bid: { amount: 0.05 },
        match_type: 'Exact',
        text: 'AcceptanceTestKeyword'
      } }
    )
  end

  def clean_keywords
    response = get_keywords_by_ad_group_id[:keywords]

    unless response == ''
      keyword_ids = response[:keyword].map do |record|
        record[:id]
      end

      delete_keywords(keyword_ids)
    end
  end

  def delete_keywords(keyword_ids)
    response = api.campaign_management.delete_keywords(
      ad_group_id: ad_group_id,
      keyword_ids: keyword_ids.map { |long| {long: long} }
    )

    reset_example_keywords

    response
  end

  def get_keywords_by_ad_group_id
    api.campaign_management.get_keywords_by_ad_group_id(
      ad_group_id: ad_group_id
    )
  end
end
