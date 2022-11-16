# frozen_string_literal: true

require_relative '../examples'

RSpec.describe 'Budget methods' do
  include_context 'use api'

  let(:budget_id) { add_budget[:budget_ids].first }

  let(:add_budget) do
    api.campaign_management.call(:add_budgets,
                                 budgets: [
                                   budget: {
                                     amount: '10',
                                     budget_type: 'DailyBudgetStandard',
                                     name: "test_budget #{random}"
                                   }
                                 ])
  end

  describe '#add_budget' do
    it 'returns budget ids for created Budgets' do
      expect(add_budget).to include(
        budget_ids: [a_kind_of(Integer)],
        partial_errors: ''
      )
    end
  end

  describe '#get_budgets_by_ids' do
    before { add_budget }

    it 'returns a list of budgets' do
      expect(api.campaign_management.get_budgets_by_ids(
               budget_ids: [long: budget_id]
             )).to include({
                             amount: '10.00',
                             association_count: '0',
                             budget_type: 'DailyBudgetStandard',
                             id: a_kind_of(String),
                             name: a_string_starting_with('test_budget')
                           })
    end
  end

  describe '#delete_budgets' do
    before { add_budget }

    it 'returns no errors' do
      expect(api.campaign_management.call(:delete_budgets,
                                          budget_ids: [{ long: budget_id }])).to eq(partial_errors: '')
    end
  end
end
