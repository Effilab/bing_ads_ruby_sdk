require_relative '../example_helper'
require 'securerandom'

RSpec.describe 'CustomerManagement service' do
  include_context 'use api'
  let(:customer_id) { signup_customer[:customer_id] }
  let(:account_id) { signup_customer[:account_id] }

  subject(:get_customer) do
    api.customer_management.get_customer(customer_id: customer_id)
  end

  subject(:get_account) do
    api.customer_management.get_account(account_id: account_id)
  end

  subject(:signup_customer) do
    api.customer_management.signup_customer(
      customer: {
        customer_address: {
          city: 'Paris',
          postal_code: 75_001,
          line1: '1 rue de Rivoli',
          country_code: 'FR',
        },
        industry: 'Entertainment',
        name: "Test Customer #{SecureRandom.hex}",
      },
      advertiser_account: {
        name: "Test Account #{SecureRandom.hex}",
        currency_type: 'USDollar',
      },
      parent_customer_id: CUSTOMER_ID
    )
  end

  describe 'Account methods' do
    describe '#find_accounts' do
      subject do
        api.customer_management.find_accounts(
          application_scope: 'Advertiser',
          account_filter: '',
          customer_id: CUSTOMER_ID,
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
          application_scope: 'Advertiser',
          filter: '',
          top_n: 1
        )
      end

      it 'returns a list of records containing account / customer pairs' do
        is_expected.to include(
          account_info_with_customer_data: {
            account_info_with_customer_data: [
              {
                customer_id: a_kind_of(String),
                customer_name: a_kind_of(String),
                account_id: a_kind_of(String),
                account_name: a_kind_of(String),
                account_number: a_kind_of(String),
                account_life_cycle_status: a_kind_of(String), # e.g. 'Active'
                pause_reason: nil,
              },
            ],
          }

        )
      end
    end

    describe '#get_account' do
      it 'returns information about the current account' do
        expect(get_account).to include(
          account: {
            account_type: "Advertiser",
            bill_to_customer_id: a_kind_of(String),
            country_code: a_kind_of(String),
            currency_type: "USDollar",
            account_financial_status: "ClearFinancialStatus",
            id: a_kind_of(String),
            language: "English",
            forward_compatibility_map: {
              key_value_pair_ofstringstring: [
                {
                  key: "AutoTag",
                  value: "0",
                },
              ],
            },
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
            time_zone: "PacificTimeUSCanadaTijuana",
            pause_reason: nil,
            linked_agencies: {
              customer_info: {
                id: a_kind_of(String),
                name: a_kind_of(String),
              },
            },
            sales_house_customer_id: nil,
            tax_information: {
              key_value_pair_ofstringstring: {
                key: "TaxId",
                value: nil
              }
            },
            back_up_payment_instrument_id: nil,
            billing_threshold_amount: nil,
          }
        )
      end
    end

    describe '#update_account' do
      let(:account) { get_account[:account] }
      subject do
        api.customer_management.update_account(
          advertiser_account: {
            id: account[:id],
            time_stamp: account[:time_stamp],
            name: "#{account[:time_stamp]} - updated",
          }
        )
      end

      it 'returns the last modified time' do
        is_expected.to include(last_modified_time: a_kind_of(String))
      end
    end

    describe '#delete_account' do
      let(:account) { get_account[:account] }

      subject do
        api.customer_management.delete_account(
          account_id: account[:id],
          time_stamp: account[:time_stamp]
        )
      end

      it 'returns an empty string' do
        is_expected.to eq('')
      end
    end
  end

  describe 'Customer methods' do
    describe '#signup_customer' do
      it 'returns customer ids' do
        expect(signup_customer).to include(
          customer_id: a_kind_of(String),
          customer_number: a_kind_of(String),
          account_id: a_kind_of(String),
          account_number: a_kind_of(String),
          create_time: a_kind_of(String)
        )
      end
    end

    describe 'get_customer' do
      it 'returns customer data' do
        expect(get_customer).to include(
          customer: {
            customer_address: {
              city: "Paris",
              country_code: "FR",
              id: a_kind_of(String),
              line1: "1 rue de Rivoli",
              line2: nil,
              line3: nil,
              line4: nil,
              postal_code: "75001",
              state_or_province: "",
              time_stamp: a_kind_of(String),
            },
            customer_financial_status: "ClearFinancialStatus",
            id: a_kind_of(String),
            industry: "Entertainment",
            last_modified_by_user_id: a_kind_of(String),
            last_modified_time: a_kind_of(String),
            market_country: "US",
            forward_compatibility_map: {
              key_value_pair_ofstringstring: [
                {
                  key: "ManagedByCustomerId",
                  value: "0",
                },
              ],
            },
            market_language: "English",
            name: a_string_starting_with("Test Customer"),
            service_level: "SelfServe",
            customer_life_cycle_status: "Active",
            time_stamp: a_kind_of(String),
            number: a_kind_of(String),
          }
        )
      end
    end

    describe '#get_customers_info' do
      subject do
        api.customer_management.get_customers_info(
          application_scope: 'Advertiser',
          customer_name_filter: '',
          top_n: 1
        )
      end

      it 'returns a list of simple customer information' do
        is_expected.to include(
          customers_info: {
            customer_info: [
              {
                id: a_kind_of(String),
                name: a_kind_of(String),
              },
            ],
          }
        )
      end
    end

    describe '#update_customer' do
      let(:original_customer) { get_customer }
      let(:updated_customer) do
        original_customer.tap do |record|
          record[:customer][:name] = 'updated name'
        end
      end

      subject do
        api.customer_management.update_customer(updated_customer)
      end

      it 'returns the update timestamp' do
        is_expected.to include(last_modified_time: a_kind_of(String)) # 2017-08-29T07:42:34.363
      end
    end

    describe '#delete_customer' do
      let(:customer_record) { get_customer[:customer] }

      subject(:delete_customer) do
        api.customer_management.delete_customer(
          customer_id: customer_record[:id],
          time_stamp: customer_record[:time_stamp]
        )
      end

      it 'fails because the user lacks rights' do
        expect { delete_customer }
          .to raise_error(BingAdsRubySdk::Errors::ApiFault)
      end
    end
  end

  describe 'User methods' do
    describe '#get_user' do
      subject do
        api.customer_management.get_user(user_id: USER_ID)
      end

      it 'returns a User record' do
        is_expected.to include(
          user: {
            contact_info: {
             address: {
               city: "Boulogne-Billancourt",
               country_code: "FR",
               id: a_kind_of(String),
               line1: "54 Avenue du Général Leclerc",
               line2: nil,
               line3: nil,
               line4: nil,
               postal_code: "92100",
               state_or_province: "01",
               time_stamp: a_kind_of(String),
             },
             contact_by_phone: "false",
             contact_by_postal_mail: "false",
             email: a_kind_of(String),
             email_format: "Html",
             fax: nil,
             home_phone: nil,
             id: a_kind_of(String),
             mobile: nil,
             phone1: "0000000",
             phone2: nil,
            },
            customer_app_scope: nil,
            customer_id: a_kind_of(String),
            id: a_kind_of(String),
            job_title: nil,
            last_modified_by_user_id: a_kind_of(String),
            last_modified_time: a_kind_of(String), # 2017-08-28T16:03:59.09
            lcid: "EnglishUS",
            name: {
             first_name: "SoLocal",
             last_name: "Effilab",
             middle_initial: nil,
            },
            password: nil,
            secret_answer: nil,
            secret_question: "None",
            user_life_cycle_status: "Active",
            time_stamp: a_kind_of(String),
            user_name: a_kind_of(String),
            is_migrated_to_microsoft_account: "true",
            },
            roles: { int: a_kind_of(Array) }, # { int: ['53', '54'] },
            accounts: "",
            customers: ""
          )
      end
    end

    describe '#get_users_info' do
      subject do
        api.customer_management.get_users_info(
          customer_id: CUSTOMER_ID,
          status_filter: 'Active'
        )
      end

      it 'returns a list of basic user information' do
        is_expected.to include(
         users_info: {
           user_info: a_collection_including(
                            id: a_kind_of(String),
                            user_name: a_kind_of(String)
           ),
         }
        )
      end
    end

    # TODO: We should perhaps do this later when we can delete users
    # def test_update_user
    #   user = get_user(USER_ID)
    #   user[:user][:contact_info][:job_title] = 'Updated title'
    #
    #   api.customer_management.update_user(user)
    # end
  end
end
