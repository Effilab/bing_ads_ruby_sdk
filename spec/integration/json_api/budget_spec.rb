# frozen_string_literal: true

RSpec.describe "JSON Budget API" do
  include_context "json api with vcr"

  it "creates a shared budget" do
    use_json_api_cassette("budget_creates_shared_budget") do
      with_budget do |budget_id, response|
        expect(response[:BudgetIds]).to include(budget_id)
      end
    end
  end

  it "updates a shared budget" do
    use_json_api_cassette("budget_updates_shared_budget") do
      with_budget do |budget_id|
        response = api.campaign_management.update_budgets(
          budgets: [{id: budget_id, name: "SDK VCR Budget Updated", amount: 2, budget_type: "DailyBudgetStandard"}]
        )

        expect(response[:PartialErrors]).to eq([])
        budget = api.campaign_management.get_budgets_by_ids(budget_ids: [budget_id])[:Budgets].first
        expect(budget[:Name]).to eq("SDK VCR Budget Updated")
      end
    end
  end

  it "deletes a shared budget" do
    use_json_api_cassette("budget_deletes_shared_budget") do
      with_budget do |budget_id|
        response = api.campaign_management.delete_budgets(budget_ids: [budget_id])

        expect(response[:PartialErrors]).to eq([])
        @budget_deleted = true
      end
    end
  end
end
