require 'lolsoap'
require 'net/http'
require 'open-uri'
require 'bing_ads_ruby_sdk/oauth2/authorization_code'

module BingAdsRubySdk
  class Service
    attr_reader :client
    attr_reader :token
    attr_reader :credentials

    def initialize(url, credentials)
      @client = LolSoap::Client.new(File.read(open(url)))
      @token  = BingAdsRubySdk::OAuth2::AuthorizationCode.new(
        developer_token: credentials[:developer_token],
        client_id:       credentials[:client_id]
      )
      @credentials = credentials
      operations.keys.each do |op|
        define_singleton_method(snakize(op)) { |body = false| request(op, body) }
      end
    end

    def snakize(string)
      string.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
    end

    def operations
      client.wsdl.operations
    end

    def request(name, body)
      req = client.request(name)
      req.header.content(
        authentication_token: token.fetch_or_refresh,
        developer_token:      credentials[:developer_token],
        customer_id:          credentials[:customer_id],
        customer_account_id:  credentials[:customer_account_id]
      )

      req.body.content(body) if body
      puts req.content
      raw_response = Net::HTTP.post(URI(req.url), req.content, req.headers)
      client.response(req, raw_response.body).body_hash
    end
  end
end
