require 'signet/oauth_2/client'
require 'bing_ads_ruby_sdk/oauth2/fs_store'
# @todo add and verify state with SecureRandom.hex(10)
# require 'securerandom'

module BingAdsRubySdk
  module OAuth2
    # Adds some usefull methods to Signet::OAuth2::Client
    class AuthorizationCode
      attr_reader :client
      attr_reader :store
      # get or fech an access token
      def fetch_or_refresh
        if client.expired?
          client.refresh!
          store.write(token_data)
        end
        client.access_token
      end

      # @param config [Hash] mandatory parameters to initialize the client.
      # @option config [Symbol] :developer_token
      # @option config [Symbol] :client_id
      # @param store [Class] default FsStore
      # @see FsStore
      def initialize(config, store: FsStore)
        @client = initialize_client(config)
        @store  = store.new(token_key)
        refresh_from_store
      end

      # @param [String] code authorization code from bing's ads.
      # @see Rake oauth2 tasks
      def fetch_from_code(code)
        client.code = code
        client.fetch_access_token!
        store.write(token_data)
      end

      # Refresh token from previous refresh!
      def refresh_from_store
        ext_token = store.read
        client.update_token!(ext_token) if ext_token
      end

      private

      def initialize_client(config)
        Signet::OAuth2::Client.new({
          authorization_uri:    'https://login.live.com/oauth20_authorize.srf',
          token_credential_uri: 'https://login.live.com/oauth20_token.srf',
          redirect_uri:         'https://login.live.com/oauth20_desktop.srf'
        }.merge(config))
      end

      def token_data
        %i[access_token
           refresh_token
           issued_at
           expires_in].each_with_object({}) do |k, h|
          h[k] = client.send(k)
        end
      end

      def token_key
        return nil if client.client_id.nil?
        @token_key ||= "token_#{client.client_id}"
      end
    end
  end

  # unless ARGV.empty? || ARGV.first.empty?
  #   OAuth2::AuthorizationCode.token_from_code(ARGV.first)
  # end
end
