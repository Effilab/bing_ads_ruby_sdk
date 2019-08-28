require 'signet/oauth_2/client'
require 'bing_ads_ruby_sdk/oauth2/fs_store'

module BingAdsRubySdk
  module OAuth2
    # Adds some useful methods to Signet::OAuth2::Client
    class AuthorizationHandler

      # @param developer_token
      # @param client_id
      # @param store [Store]
      def initialize(developer_token:, client_id:, store:, client_secret:)
        @client = build_client(developer_token, client_id, client_secret)
        @store  = store
        refresh_from_store
      end

      # @return [String] unless client.client_id url is nil interpolated url.
      # @return [nil] if client.client_id is nil.
      def code_url
        return nil if client.client_id.nil?
        "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=#{client.client_id}&"\
        "scope=offline_access+https://ads.microsoft.com/ads.manage&response_type=code&"\
        "redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient"
      end

      # Once you have completed the oauth process in your browser using the code_url
      # copy the url your browser has been redirected to and use it as argument here
      def fetch_from_url(url)
        codes = extract_codes(url)

        return false if codes.none?
        fetch_from_code(codes.last)
      rescue Signet::AuthorizationError, URI::InvalidURIError
        false
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

      def build_client(developer_token, client_id, client_secret)
        Signet::OAuth2::Client.new({
          authorization_uri:    'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
          token_credential_uri: 'https://login.microsoftonline.com/common/oauth2/v2.0/token',
          redirect_uri:         'https://login.microsoftonline.com/common/oauth2/nativeclient',
          client_secret:        client_secret,
          developer_token: developer_token,
          client_id: client_id,
          scope: 'offline_access'
        })
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
