# frozen_string_literal: true

module BingAdsRubySdk
  # Contains the SOAP Request header informations
  class Header
    # @param credentials [Hash] to be used for API authorization
    # @option credentials :developer_token [String]
    # @param oauth_store instance of a store
    def initialize(credentials, oauth_store)
      @credentials = credentials
      @oauth_store = oauth_store
      @customer = {}
    end

    # @return [Hash] Authorization and identification data that will be added to the SOAP header
    def content
      {
        "AuthenticationToken" => auth_handler.fetch_or_refresh,
        "DeveloperToken" =>      credentials[:developer_token],
        "CustomerId" =>          customer[:id],
        "CustomerAccountId" =>   customer[:account_id]
      }
    end

    def set_customer(hash)
      customer[:account_id] = hash.fetch(:account_id)
      customer[:id] = hash.fetch(:id)
      self
    end

    private

    attr_reader :oauth_store, :credentials, :customer

    def auth_handler
      @auth_handler ||= ::BingAdsRubySdk::OAuth2::AuthorizationHandler.new(
        {
          developer_token: credentials[:developer_token],
          client_id:       credentials[:client_id],
        },
        { store: oauth_store }
      )
    end
  end
end
