# frozen_string_literal: true
require 'bing_ads_ruby_sdk/cache'

RSpec.shared_context 'use api' do
  # TODO: consider reading a YML file to get these values
  CUSTOMER_ID ||= ENV.fetch('ACCEPTANCE_CUSTOMER_ID')
  ACCOUNT_ID ||= ENV.fetch('ACCEPTANCE_ACCOUNT_ID')
  USER_ID ||= ENV.fetch('ACCEPTANCE_USER_ID')
  DEVELOPER_TOKEN ||= ENV.fetch('ACCEPTANCE_DEVELOPER_TOKEN')
  CLIENT_ID ||= ENV.fetch('ACCEPTANCE_CLIENT_ID')

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

BingAdsRubySdk::Cache.build
