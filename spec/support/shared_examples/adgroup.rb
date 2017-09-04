# frozen_string_literal: true

RSpec.shared_context 'manages adgroups' do
  include_context 'manages campaigns'

  def create_ad_group
    api.campaign_management.add_ad_groups(
      campaign_id: campaign_id,
      ad_groups: { ad_group: {
        name: 'AcceptanceTestAdGroup',
        ad_distribution: 'Search Content',
        language: 'French'
      } }
    )
  end

  def example_ad_group
    @example_ad_group ||= create_ad_group
  end

  def ad_group_id
    ad_group_ids.first
  end

  def ad_group_ids
    example_ad_group[:ad_group_ids]
  end
end
