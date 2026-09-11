# frozen_string_literal: true

RSpec.describe "JSON Conversion Goals API" do
  include_context "json api with vcr"

  let(:conversion_goal_id) { 172211594 }
  let(:uet_tag_id) { 211077200 }

  it "creates an Event conversion goal" do
    use_json_api_cassette("conversion_goals_creates_event_goal") do
      response = api.campaign_management.add_conversion_goals(
        conversion_goals: [{
          type: "Event",
          name: "SDK VCR Goal #{SecureRandom.hex(4)}",
          tag_id: uet_tag_id,
          scope: "Account",
          status: "Paused",
          goal_category: "Other",
          count_type: "All",
          conversion_window_in_minutes: 43_200,
          action_operator: "Equals",
          action_expression: "sdk_vcr_action"
        }]
      )

      expect(response[:ConversionGoalIds]).not_to be_empty
      expect(response[:PartialErrors]).to eq([])

      goal_id = response[:ConversionGoalIds].first
      by_id = api.campaign_management.get_conversion_goals_by_ids(
        conversion_goal_types: "Event",
        conversion_goal_ids: [goal_id]
      )
      by_tag = api.campaign_management.get_conversion_goals_by_tag_ids(
        conversion_goal_types: "Event",
        tag_ids: [uet_tag_id]
      )

      expect(by_id[:ConversionGoals]).to include(a_hash_including(Id: goal_id))
      expect(by_tag[:ConversionGoals]).to include(a_hash_including(Id: goal_id))
    end
  end

  it "reads an existing conversion goal by ID" do
    use_json_api_cassette("conversion_goals_reads_existing_goal") do
      response = api.campaign_management.get_conversion_goals_by_ids(
        conversion_goal_types: "Event",
        conversion_goal_ids: [conversion_goal_id]
      )

      expect(response[:ConversionGoals]).not_to be_empty
    end
  end

  it "reads conversion goals by UET tag ID" do
    use_json_api_cassette("conversion_goals_reads_by_tag_id") do
      response = api.campaign_management.get_conversion_goals_by_tag_ids(
        conversion_goal_types: "Event",
        tag_ids: [uet_tag_id]
      )

      expect(response[:ConversionGoals]).not_to be_empty
    end
  end

  it "updates an existing conversion goal" do
    use_json_api_cassette("conversion_goals_updates_existing_goal") do
      response = api.campaign_management.update_conversion_goals(
        conversion_goals: [{id: conversion_goal_id, name: "SDK VCR Existing Goal", type: "Event"}]
      )

      expect(response[:PartialErrors]).to eq([])
    end
  end
end
