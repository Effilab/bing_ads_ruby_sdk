# frozen_string_literal: true

require_relative '../examples'

RSpec.describe 'CustomerManagement service' do
  include_context 'use api'

  it 'creates customer' do
    created_customer = api.customer_management.signup_customer(
      customer: {
        customer_address: {
          city: 'Paris',
          postal_code: 75_001,
          line1: '1 rue de Rivoli',
          country_code: 'FR'
        },
        industry: 'Entertainment',
        name: "Test Customer #{random}"
      },
      account: {
        '@type' => 'AdvertiserAccount',
        :name => "Test Account #{random}",
        :currency_code => 'USD'
      },
      parent_customer_id: Examples.parent_customer_id
    )
    expect(created_customer).to include(
      customer_id: a_kind_of(String),
      customer_number: a_kind_of(String),
      account_id: a_kind_of(String),
      account_number: a_kind_of(String),
      create_time: a_kind_of(String)
    )

    puts "You can now fill in examples.rb with customer_id: #{created_customer[:customer_id]} and account_id: #{created_customer[:account_id]}"
  end
end
