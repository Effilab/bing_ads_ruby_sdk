# frozen_string_literal: true

require_relative '../examples'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'

  describe 'Campaign methods' do
    it 'returns campaign ids' do
      campaigns = api.campaign_management.call(:add_campaigns,
                                               account_id: Examples.account_id,
                                               campaigns: {
                                                 campaign:
                                                   {
                                                     name: "Acceptance Test Campaign #{random}",
                                                     daily_budget: 10,
                                                     budget_type: 'DailyBudgetStandard',
                                                     time_zone: 'BrusselsCopenhagenMadridParis'
                                                   }
                                               })
      expect(campaigns).to include(
        partial_errors: '',
        campaign_ids: [a_kind_of(Integer)]
      )
      puts "You can now fill in examples.rb with campaign_id: #{campaigns[:campaign_ids].first}"
    end
  end
end
