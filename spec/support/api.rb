# frozen_string_literal: true
RSpec.shared_context 'use api' do
  # TODO: consider reading a YML file to get these values
  CUSTOMER_ID ||= ENV.fetch('BING_PARENT_CUSTOMER_ID')
  DEVELOPER_TOKEN ||= ENV.fetch('BING_DEVELOPER_TOKEN')
  CLIENT_ID ||= ENV.fetch('BING_CLIENT_ID')

  # exists only once you have created one
  ACCOUNT_ID ||= ENV['ACCEPTANCE_ACCOUNT_ID']
  USER_ID ||= ENV['ACCEPTANCE_USER_ID']

  def api
    @api ||= BingAdsRubySdk::Api.new(
      credentials: {
        developer_token: DEVELOPER_TOKEN,
        client_id: CLIENT_ID
      }
    ).tap do |api|
      api.set_customer(
        id: CUSTOMER_ID,
        account_id: ACCOUNT_ID
      )
    end
  end
end
