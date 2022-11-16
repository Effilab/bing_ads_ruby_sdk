# frozen_string_literal: true

require_relative '../examples'

RSpec.describe 'CampaignCriterion methods' do
  include_context 'use api'

  def add_campaign_criterions(location_id)
    api.campaign_management.call(:add_campaign_criterions,
                                 campaign_criterions: [
                                   {
                                     negative_campaign_criterion: {
                                       campaign_id: Examples.campaign_id,
                                       location_criterion: {
                                         location_id: location_id
                                       }
                                     }
                                   }
                                 ],
                                 criterion_type: 'Targets')
  end

  describe '#add_campaign_criterions' do
    it 'returns CampaignCriterion ids' do
      expect(add_campaign_criterions(190)).to include(
        campaign_criterion_ids: [a_kind_of(Integer)],
        nested_partial_errors: ''
      )
    end
  end

  describe '#delete_campaign_criterions' do
    it 'returns no errors' do
      response = add_campaign_criterions(191)

      expect(api.campaign_management.call(:delete_campaign_criterions,
                                          campaign_criterion_ids: [
                                            { long: response[:campaign_criterion_ids].first }
                                          ],
                                          campaign_id: Examples.campaign_id,
                                          criterion_type: 'Targets')).to eq(
                                            partial_errors: ''
                                          )
    end
  end

  describe '#get_campaign_criterions_by_ids' do
    it 'returns CampaignCriterions' do
      response = add_campaign_criterions(193)
      criterion_id = response[:campaign_criterion_ids].first.to_s

      criterions = api.campaign_management.get_campaign_criterions_by_ids(
        campaign_criterion_ids: [{ long: criterion_id }],
        campaign_id: Examples.campaign_id,
        criterion_type: 'Age DayTime Device Gender Location LocationIntent Radius'
      )

      expect(criterions).to include(
        campaign_id: Examples.campaign_id.to_s,
        criterion: {
          type: 'LocationCriterion',
          display_name: a_kind_of(String),
          enclosed_location_ids: nil,
          location_id: '193',
          location_type: a_kind_of(String)
        },
        forward_compatibility_map: nil,
        id: criterion_id,
        status: a_kind_of(String),
        type: 'NegativeCampaignCriterion'
      )
    end
  end
end
