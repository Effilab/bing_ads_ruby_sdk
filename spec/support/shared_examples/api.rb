# frozen_string_literal: true

RSpec.shared_context 'use api' do
  # TODO: consider reading a YML file to get these values
  CUSTOMER_ID = ENV['ACCEPTANCE_CUSTOMER_ID']
  ACCOUNT_ID = ENV['ACCEPTANCE_ACCOUNT_ID']
  USER_ID = ENV['ACCEPTANCE_USER_ID']
  DEVELOPER_TOKEN = ENV['ACCEPTANCE_DEVELOPER_TOKEN']
  CLIENT_ID = ENV['ACCEPTANCE_CLIENT_ID']


  def api
    @api ||= BingAdsRubySdk::Api.new(
      credentials: {
        developer_token: DEVELOPER_TOKEN,
        client_id: CLIENT_ID
      }
    ).tap do |api|
      api.customer(id:         CUSTOMER_ID,
                   account_id: ACCOUNT_ID)
    end
  end
end