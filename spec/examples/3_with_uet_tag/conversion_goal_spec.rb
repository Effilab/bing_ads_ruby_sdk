require_relative '../examples'

RSpec.describe 'Conversion goals methods' do
  include_context 'use api'

  it 'returns a list of Conversion goal Ids' do
    conversion_goals = api.campaign_management.add_conversion_goals(
      conversion_goals: {
        event_goal: {
          conversion_window_in_minutes: 43_200, # 30days
          count_type: 'All',
          name: "Acceptance Test Conversion goal #{random}",
          revenue: {
            currency_code: 'EUR',
            type: 'FixedValue',
            value: 5.20,
          },
          scope: 'Account',
          status: 'Active',
          tag_id: Examples.uet_tag_id,
          action_operator: 'Equals',
          action_expression: 'display_phone',
          category_operator: 'Equals',
          category_expression: 'contact_form',
          label_operator: 'Equals',
          label_expression: 'lower_button',
          value_operator: 'Equals',
          value: '1'
        }
      }
    )

    expect(conversion_goals).to include(
      conversion_goal_ids: [a_kind_of(Integer)],
      partial_errors: ''
    )

    puts "Please fill in examples.rb with conversion_goal_id: #{conversion_goals[:conversion_goal_ids].first}"
  end
end
