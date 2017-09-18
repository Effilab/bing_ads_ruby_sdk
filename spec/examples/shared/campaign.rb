# frozen_string_literal: true

require 'securerandom'

RSpec.shared_examples 'manages campaigns' do
  def create_campaign
    clean_campaigns
    api.campaign_management.add_campaigns(
      account_id: ACCOUNT_ID,
      campaigns: {
        campaign:
          {
            name: "Acceptance Test Campaign #{ SecureRandom.hex }",
            daily_budget: 10,
            budget_type: 'DailyBudgetStandard',
            time_zone: 'BrusselsCopenhagenMadridParis',
            description: 'This campaign was automatically generated in a test'
          }
      }
    )
  end

  def clean_campaigns
    existing_campaigns = api.campaign_management.get_campaigns_by_account_id(
      account_id: ACCOUNT_ID
    )

    return nil if existing_campaigns[:campaigns].empty?

    campaign_ids = existing_campaigns[:campaigns][:campaign].map do |c|
      c[:id] if c[:name].start_with?('Acceptance Test Campaign')
    end.compact

    return nil if campaign_ids.empty?

    api.campaign_management.delete_campaigns(
      account_id: ACCOUNT_ID,
      campaign_ids: campaign_ids.map { |id| { long: id } }
    )

    reset_example_campaign
  end

  def example_campaign
    @example_campaign ||= create_campaign
  end

  def reset_example_campaign
    @example_campaign = nil
    reset_example_ad_group
  end

  def campaign_id
    example_campaign[:campaign_ids].first
  end

  def reset_example_ad_group
    @example_ad_group = nil
    reset_example_keywords
  end

  def reset_example_keywords
    @example_keywords = nil
  end
end
