module BingAdsRubySdk
  # Contains the SOAP Request header informations
  class Header
    # @param credentials [Hash] to be used for API authorization
    # @option credentials :developer_token [String]
    # @param token [OAuth2::AuthorizationCode] instance of an AuthorizationCode
    def initialize(credentials, oauth_store)
      @credentials = credentials
      @token       = build_token(oauth_store)
      @customer    = {}
    end

    # @return [Hash] Authorization and identification data that will be added to the SOAP header
    def content
      {
        "AuthenticationToken" => token.fetch_or_refresh,
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

    attr_reader :token, :credentials, :customer

    def build_token(store)
      OAuth2::AuthorizationCode.new(
        {
          developer_token: credentials[:developer_token],
          client_id:       credentials[:client_id],
        },
        { store: store }
      )
    end
  end
end
