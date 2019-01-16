require 'signet/oauth_2/client'
require 'bing_ads_ruby_sdk/oauth2/store/fs_store'
# @todo see if we need to add and verify state with SecureRandom.hex(10)
# We need the state param where we use a web UI.
# require 'securerandom'

module BingAdsRubySdk
  module OAuth2
    # Adds some useful methods to Signet::OAuth2::Client
    class AuthorizationCode

      # @param config [Hash] mandatory parameters to initialize the client.
      # @option config [Symbol] :developer_token
      # @option config [Symbol] :client_id
      # @param store [Store]
      def initialize(config, store:)
        @client = build_client(config)
        @store  = store
        refresh_from_store
      end

      # Get or fetch an access token.
      # @return [String] The access token.
      def fetch_or_refresh
        if client.expired?
          client.refresh!
          store.write(token_data)
        end
        client.access_token
      end

      def fetch_from_url(url = nil)
        return false if url.blank?
        codes = extract_codes(url)

        return false if codes.none?
        fetch_from_code(codes.last)
      rescue Signet::AuthorizationError, URI::InvalidURIError
        false
      end

      # @return [String] unless client.client_id url is nil interpolated url.
      # @return [nil] if client.client_id is nil.
      def code_url
        return nil if client.client_id.nil?
        "https://login.live.com/oauth20_authorize.srf?client_id=#{client.client_id}&scope=bingads.manage&response_type=code&redirect_uri=https://login.live.com/oauth20_desktop.srf"
      end

      private

      attr_reader :client, :store

      # Refresh existing authorization token
      # @return [Signet::OAuth2::Client] if everything went well.
      # @return [nil] if the token can't be read from the store.
      def refresh_from_store
        ext_token = store.read
        client.update_token!(ext_token) if ext_token
      end

      # Request the Api to exchange the code for the access token.
      # Save the access token through the store.
      # @param [String] code authorization code from bing's ads.
      # @return [#store.write] store's write output.
      def fetch_from_code(code)
        client.code = code
        client.fetch_access_token!
        store.write(token_data)
      end

      def extract_codes(url)
        url = URI.parse(url)
        query_params = URI.decode_www_form(url.query)
        query_params.find { |arg| arg.first.casecmp("CODE").zero? }
      end

      def build_client(config)
        Signet::OAuth2::Client.new({
          authorization_uri:    'https://login.live.com/oauth20_authorize.srf',
          token_credential_uri: 'https://login.live.com/oauth20_token.srf',
          redirect_uri:         'https://login.live.com/oauth20_desktop.srf'
        }.merge(config))
      end

      def token_data
        {
          access_token: client.access_token,
          refresh_token: client.refresh_token,
          issued_at: client.issued_at,
          expires_in: client.expires_in
        }
      end
    end
  end
end
