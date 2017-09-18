require_relative '../example_helper'
require 'securerandom'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'

  describe 'Budget methods' do
    let(:budget_id) { add_budget[:budget_ids].first }

    subject(:add_budget) do
      api.campaign_management.add_budgets(
        budgets: [
          budget: {
            amount: '10',
            budget_type: 'DailyBudgetStandard',
            name: "test_budget #{SecureRandom.hex}",
          },
        ]
      )
    end

    describe '#add_budget' do
      it 'returns budget ids for created Budgets' do
        expect(add_budget).to include(budget_ids: [a_kind_of(Integer)],
                                      partial_errors: '')
      end
    end

    describe '#get_budgets_by_ids' do
      before { add_budget }
      subject do
        api.campaign_management.get_budgets_by_ids(
          budget_ids: [long: budget_id]
        )
      end

      it 'returns a list of budgets' do
        is_expected.to include(
          budgets: {
            budget: [
              {
                amount: '10.00',
                association_count: '0',
                budget_type: 'DailyBudgetStandard',
                id: a_kind_of(String),
                name: a_string_starting_with('test_budget'),
              },
            ],
          },
          partial_errors: ''
        )
      end
    end

    describe '#delete_budgets' do
      subject do
        api.campaign_management.delete_budgets(
          budget_ids: [long: budget_id]
        )
      end

      it 'returns no errors' do
        is_expected.to eq(partial_errors: '')
      end
    end
  end
end
