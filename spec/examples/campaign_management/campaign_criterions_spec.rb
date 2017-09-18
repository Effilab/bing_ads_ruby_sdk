require_relative '../example_helper'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'
  include_context 'manages campaigns'

  describe 'CampaignCriterion methods' do
    let(:criterion_ids) do
      add_campaign_criterions[:campaign_criterion_ids]
    end

    subject(:add_campaign_criterions) do
      api.campaign_management.add_campaign_criterions(
        campaign_criterions: [
          {
            negative_campaign_criterion: {
              campaign_id: campaign_id,
              location_criterion: {
                display_name: 'United States',
                location_id: 190,
              },
              id: nil,
            },
          },
        ],
        criterion_type: 'Targets'
      )
    end

    describe '#add_campaign_criterions' do
      subject { add_campaign_criterions }

      it 'returns CampaignCriterion ids' do
        is_expected.to include(
          campaign_criterion_ids: [a_kind_of(Integer)],
          is_migrated: 'false',
          nested_partial_errors: ''
        )
      end
    end

    describe '#delete_campaign_criterions' do
      subject do
        api.campaign_management.delete_campaign_criterions(
          campaign_criterion_ids: [
            { long: criterion_ids.first },
          ],
          campaign_id: campaign_id,
          criterion_type: 'Targets'
        )
      end

      it 'returns no errors' do
        is_expected.to eq(
                         is_migrated: 'false',
                         partial_errors: ''
        )
      end
    end

    describe '#get_campaign_criterions_by_ids' do
      before { add_campaign_criterions }

      subject(:get_campaign_criterions) do
        api.campaign_management.get_campaign_criterions_by_ids(
          # Specifying ids raises errors at this stage
          # campaign_criterion_ids: [{ long: criterion_ids.first }],
          campaign_id: campaign_id,
          criterion_type: 'Age DayTime Device Gender Location LocationIntent Radius'
        )
      end

      let(:criterion_array) do
        get_campaign_criterions[:campaign_criterions][:campaign_criterion]
      end

      it 'returns CampaignCriterions' do
        is_expected.to include(
          campaign_criterions: {
           campaign_criterion: a_kind_of(Array),
          },
          partial_errors: nil
        )

        expect(criterion_array).to include(
          campaign_id: campaign_id.to_s,
          criterion: {
           type: 'LocationCriterion',
           display_name: 'United States',
           enclosed_location_ids: nil,
           location_id: '190',
           location_type: 'Country',
          },
          forward_compatibility_map: nil,
          id: a_kind_of(String),
          status: 'Active',
          type: 'NegativeCampaignCriterion'
        )
      end
    end

    describe '#update_campaign_criterions' do
      let(:criterion_id) { criterion_ids.first }

      subject do
        # NOTE: this method doesn't really seem to update anything. This is
        # because the LocationCriterion record isn't really updateable.
        # perhaps a better example could be found with a different criterion type
        api.campaign_management.update_campaign_criterions(
          campaign_criterions: [
            {
              negative_campaign_criterion: {
                campaign_id: campaign_id,
                location_criterion: {
                  display_name: 'The States',
                  location_id: 190,
                },
                id: criterion_id,
              },
            },
          ],
          criterion_type: 'Targets'
        )
      end

      it 'returns no errors' do
        is_expected.to eq(
          is_migrated: 'false',
          nested_partial_errors: ''
        )
      end
    end
  end
end
