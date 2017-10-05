require_relative '../example_helper'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'

  describe 'Conversion goals methods' do
    let(:uet_tag_id) do
      api.campaign_management.add_uet_tags(
        uet_tags: {
          uet_tag: {
            description: 'UET Tag Description',
            name: "Acceptance Test UET Tag #{SecureRandom.hex}",
          },
        }
      )[:uet_tags][:uet_tag].first[:id]
    end
    let(:conversion_goal_id) { add_conversion_goals[:conversion_goal_ids].first }

    subject(:add_conversion_goals) do
      api.campaign_management.add_conversion_goals(
        conversion_goals: {
          event_goal: {
            conversion_window_in_minutes: 43_200, # 30days
            count_type: 'All',
            name: "Acceptance Test Conversion goal #{SecureRandom.hex}",
            revenue: {
              currency_code: 'EUR',
              type: 'FixedValue',
              value: 5.20,
            },
            scope: 'Account',
            status: 'Active',
            tag_id: uet_tag_id,
            type: 'Event',

            # ConversionGoal fields
            action_operator: 'Equals',
            action_expression: 'display_phone',

            category_operator: 'Equals',
            category_expression: 'contact_form',

            label_operator: 'Equals',
            label_expression: 'lower_button',

            value_operator: 'Equals',
            value: '1',
          },
        }
      )
    end

    def get_conversions_without_memo(id)
      api.campaign_management.get_conversion_goals_by_ids(
        conversion_goal_types: 'Event',
        conversion_goal_ids: [{ long: id }]
      )
    end

    subject(:get_conversion_goals_by_ids) do
      get_conversions_without_memo(conversion_goal_id)
    end

    let(:a_list_of_conversion_goals) do
      {
        conversion_goals: {
          # Note that the operation returns :conversion_goal as the key
          # regardless of the inherited ConversionGoal type. You can figure
          # out what type the ConversionGoal is by the 'type' field.
          conversion_goal: [
            {
              conversion_window_in_minutes: '43200',
              count_type: 'All',
              id: a_kind_of(String),
              name: a_string_starting_with('Acceptance Test Conversion goal'),
              revenue: {
                currency_code: 'EUR',
                type: 'FixedValue',
                value: '5.2000',
              },
              scope: 'Account',
              status: 'Active',
              tag_id: uet_tag_id.to_s,
              tracking_status: 'TagUnverified',
              type: 'Event',
              action_expression: 'display_phone',
              action_operator: 'Equals',
              category_expression: 'contact_form',
              category_operator: 'Equals',
              label_expression: 'lower_button',
              label_operator: 'Equals',
              value: '1.0000',
              value_operator: 'Equals',
            },
          ],
        },
        partial_errors: '',
      }
    end

    describe '#add_conversion_goals' do
      it 'returns a list of Conversion goal Ids' do
        expect(add_conversion_goals).to include(conversion_goal_ids: [a_kind_of(Integer)],
                                                partial_errors: '')
      end
    end

    describe '#get_conversion_goals_by_ids' do
      before { add_conversion_goals }

      it 'returns a list of conversion goals' do
        expect(get_conversion_goals_by_ids).to include(a_list_of_conversion_goals)
      end
    end

    describe '#get_conversion_goals_by_tag_ids' do
      before { add_conversion_goals }

      subject do
        api.campaign_management.get_conversion_goals_by_tag_ids(
          conversion_goal_types: 'Event',
          tag_ids: [long: uet_tag_id]
        )
      end

      it 'returns a list of conversion_goals' do
        is_expected.to include(a_list_of_conversion_goals)
      end
    end

    describe '#update_conversion_goals' do
      before { add_conversion_goals }

      let(:changed_conversion_goals) do
        existing_list = get_conversion_goals_by_ids

        existing_list.tap do |record_list|
          record = record_list[:conversion_goals][:conversion_goal].first
          record[:name] = "#{record[:name]} - updated"

          record_list.delete(:partial_errors)

          # rename the key to indicate EventGoal upload
          event_goal = record_list[:conversion_goals].delete(:conversion_goal)
          record_list[:conversion_goals][:event_goal] = event_goal
        end
      end

      let(:updated_conversion) do
        get_conversions_without_memo(
          conversion_goal_id
        )[:conversion_goals][:conversion_goal].first
      end

      subject do
        api.campaign_management.update_conversion_goals(
          changed_conversion_goals
        )
      end

      it 'updates the conversion goals' do
        is_expected.to eq(partial_errors: '')

        expect(updated_conversion).to include(
          name: a_string_matching(/Acceptance Test Conversion goal .* - updated/)
        )
      end
    end
  end
end
