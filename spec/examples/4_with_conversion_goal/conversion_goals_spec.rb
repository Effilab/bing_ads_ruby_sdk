require_relative "../examples"

RSpec.describe "Conversion goals methods" do
  include_context "use api"

  let(:a_conversion_goal) do
    {
      conversion_window_in_minutes: a_kind_of(String),
      count_type: a_kind_of(String),
      id: a_kind_of(String),
      name: a_string_starting_with("Acceptance Test Conversion goal"),
      revenue: a_kind_of(Hash),
      scope: a_kind_of(String),
      status: a_kind_of(String),
      tag_id: Examples.uet_tag_id.to_s,
      tracking_status: a_kind_of(String),
      type: "Event",
      action_expression: a_kind_of(String),
      action_operator: a_kind_of(String),
      category_expression: a_kind_of(String),
      category_operator: a_kind_of(String),
      label_expression: a_kind_of(String),
      label_operator: a_kind_of(String),
      value: a_kind_of(String),
      value_operator: a_kind_of(String),
      exclude_from_bidding: nil
    }
  end

  describe "#get_conversion_goals_by_ids" do
    it "returns a list of conversion goals" do
      expect(api.campaign_management.get_conversion_goals_by_ids(
        conversion_goal_types: "Event",
        conversion_goal_ids: [{long: Examples.conversion_goal_id}]
      )).to contain_exactly(a_conversion_goal)
    end
  end

  describe "#get_conversion_goals_by_tag_ids" do
    it "returns a list of conversion_goals" do
      expect(api.campaign_management.call(:get_conversion_goals_by_tag_ids, {
        conversion_goal_types: "Event",
        tag_ids: [long: Examples.uet_tag_id]
      })).to include(
        conversion_goals: {
          conversion_goal: a_collection_including(a_conversion_goal)
        },
        partial_errors: ""
      )
    end
  end

  describe "#update_conversion_goals" do
    it "updates the conversion goals" do
      expect(
        api.campaign_management.update_conversion_goals(
          conversion_goals: {
            event_goal: {
              id: Examples.conversion_goal_id,
              name: "Acceptance Test Conversion goal #{random}"
            }
          }
        )
      ).to eq(partial_errors: "")

      updated_conversion = api.campaign_management.get_conversion_goals_by_ids(
        conversion_goal_types: "Event",
        conversion_goal_ids: [{long: Examples.conversion_goal_id}]
      ).first

      expect(updated_conversion).to include(
        name: "Acceptance Test Conversion goal #{random}"
      )
    end
  end
end
