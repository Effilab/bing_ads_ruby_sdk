require_relative '../examples'

RSpec.describe 'CustomerManagement service' do
  include_context 'use api'

  let(:get_customer) do
    api.customer_management.call(:get_customer, customer_id: Examples.customer_id)
  end

  let(:get_account) do
    api.customer_management.get_account(account_id: Examples.account_id)
  end

  describe 'Account methods' do
    describe '#find_accounts' do
      subject do
        api.customer_management.call(:find_accounts,
          account_filter: '',
          customer_id: Examples.customer_id,
          top_n: 1
        )
      end

      it 'returns a list of basic account information' do
        is_expected.to include(
          accounts_info: {
            account_info: [
              {
                id: a_kind_of(String),
                name: a_kind_of(String),
                number: a_kind_of(String),
                account_life_cycle_status: a_kind_of(String),
                pause_reason: nil,
              },
            ],
          }
        )
      end
    end

    describe '#find_accounts_or_customers_info' do
      subject do
        api.customer_management.find_accounts_or_customers_info(
          filter: '',
          top_n: 1
        )
      end

      it 'returns a list of records containing account / customer pairs' do
        is_expected.to contain_exactly(
          {
            customer_id: a_kind_of(String),
            customer_name: a_kind_of(String),
            account_id: a_kind_of(String),
            account_name: a_kind_of(String),
            account_number: a_kind_of(String),
            account_life_cycle_status: a_kind_of(String), # e.g. 'Active'
            pause_reason: nil,
          }
        )
      end
    end

    describe '#get_account' do
      it 'returns information about the current account' do
        expect(get_account).to include(
          account: {
            bill_to_customer_id: a_kind_of(String),
            currency_code: "USD",
            account_financial_status: "ClearFinancialStatus",
            id: a_kind_of(String),
            language: "English",
            last_modified_by_user_id: a_kind_of(String),
            last_modified_time: a_kind_of(String),
            name: a_string_starting_with("Test Account"),
            number: a_kind_of(String),
            parent_customer_id: a_kind_of(String),
            payment_method_id: a_kind_of(String),
            payment_method_type: nil,
            primary_user_id: a_kind_of(String),
            account_life_cycle_status: "Active",
            time_stamp: a_kind_of(String),
            time_zone: a_kind_of(String),
            pause_reason: nil,
            forward_compatibility_map: nil,
            linked_agencies: {
              customer_info: [
                {
                  id: a_kind_of(String),
                  name: a_kind_of(String),
                }
              ],
            },
            sales_house_customer_id: nil,
            tax_information: "",
            back_up_payment_instrument_id: nil,
            billing_threshold_amount: nil,
            business_address: nil,
            auto_tag_type: "Inactive",
            sold_to_payment_instrument_id: nil
          }
        )
      end
    end

    describe '#update_account' do
      let(:account) { get_account[:account] }
      subject do
        api.customer_management.update_account(
          account: {
            '@type' => 'AdvertiserAccount',
            id: account[:id],
            time_stamp: account[:time_stamp],
            name: "Test Account #{Time.now} - updated",
          }
        )
      end

      it 'returns the last modified time' do
        is_expected.to include(last_modified_time: a_kind_of(String))
      end
    end
  end

  describe 'Customer methods' do
    describe 'get_customer' do
      it 'returns customer data' do
        expect(get_customer).to include(
          customer: {
            customer_financial_status: "ClearFinancialStatus",
            id: a_kind_of(String),
            industry: "Entertainment",
            last_modified_by_user_id: a_kind_of(String),
            last_modified_time: a_kind_of(String),
            market_country: "US",
            forward_compatibility_map: a_kind_of(Hash),
            market_language: "English",
            name: a_string_starting_with("Test Customer"),
            service_level: "SelfServe",
            customer_life_cycle_status: "Active",
            time_stamp: a_kind_of(String),
            number: a_kind_of(String),
            customer_address: a_kind_of(Hash),
          }
        )
      end
    end

    describe '#get_customers_info' do
      subject do
        api.customer_management.call(:get_customers_info,
          customer_name_filter: '',
          top_n: 1
        )
      end

      it 'returns a list of simple customer information' do
        is_expected.to include(
          customers_info: {
            customer_info: a_collection_including(
              {
                id: a_kind_of(String),
                name: a_kind_of(String),
              }
            )
          }
        )
      end
    end

    describe '#update_customer' do
      let(:original_customer) { get_customer }

      subject do
        api.customer_management.call(:update_customer, {
          customer: {
            name: "Test Customer - #{Time.now}",
            id: Examples.customer_id,
            time_stamp: original_customer[:customer][:time_stamp],
            industry: original_customer[:customer][:industry]
          }
        })
      end

      it 'returns the update timestamp' do
        is_expected.to include(last_modified_time: a_kind_of(String))
      end
    end
  end
end