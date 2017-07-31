require 'bing_ads_ruby_sdk/oauth2/authorization_code'

module BingAdsRubySdk
  # Shared header
  class Header
    attr_reader :credentials, :token
    attr_accessor :customer

    def initialize(credentials)
      @credentials = credentials
      @token = BingAdsRubySdk::OAuth2::AuthorizationCode.new(
        developer_token: credentials[:developer_token],
        client_id:       credentials[:client_id]
      )
    end

    def content
      { authentication_token: token.fetch_or_refresh,
        developer_token:      credentials[:developer_token],
        customer_id:          customer[:id],
        customer_account_id:  customer[:account_id] }
    end
  end
end
