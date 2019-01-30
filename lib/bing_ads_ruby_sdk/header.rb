# frozen_string_literal: true

module BingAdsRubySdk
  # Contains the SOAP Request header informations
  class Header
    # @param developer_token
    # @param client_id
    # @param store instance of a store
    def initialize(developer_token:, client_id:, store:)
      @developer_token = developer_token
      @client_id = client_id
      @oauth_store = store
      @customer = {}
    end

    # @return [Hash] Authorization and identification data that will be added to the SOAP header
    def content
      {
        "AuthenticationToken" => auth_handler.fetch_or_refresh,
        "DeveloperToken" =>      developer_token,
        "CustomerId" =>          customer[:customer_id],
        "CustomerAccountId" =>   customer[:account_id]
      }
    end

    def set_customer(account_id:, customer_id:)
      customer[:account_id] = account_id
      customer[:customer_id] = customer_id
      self
    end

    private

    attr_reader :oauth_store, :developer_token, :client_id, :customer

    def auth_handler
      @auth_handler ||= ::BingAdsRubySdk::OAuth2::AuthorizationHandler.new(
        developer_token: developer_token,
        client_id: client_id,
        store: oauth_store
      )
    end
  end
end
