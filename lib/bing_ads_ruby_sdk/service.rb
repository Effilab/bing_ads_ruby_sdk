# frozen_string_literal: true

require "lolsoap"
require "bing_ads_ruby_sdk/utils"
require "net/http"
require "excon"

# Set SSl version to TLS 1.2:
Excon.defaults[:ssl_version] = :TLSv1_2

module BingAdsRubySdk
  # Manages communication with the a defined SOAP service on the API
  class Service
    @http_connections = {}
    HTTP_OPEN_TIMEOUT = 10
    HTTP_READ_TIMEOUT = 20
    HTTP_RETRY_COUNT_ON_TIMEOUT = 2
    HTTP_INTERVAL_RETRY_COUNT_ON_TIMEOUT = 1

    class << self
      attr_accessor :http_connections

      def connection(host)
        self.http_connections[host] ||= Excon.new(
          host,
          persistent: true,
          tcp_nodelay: true,
          retry_limit: HTTP_RETRY_COUNT_ON_TIMEOUT,
          idempotent: true,
          retry_interval: HTTP_INTERVAL_RETRY_COUNT_ON_TIMEOUT,
          connect_timeout: HTTP_OPEN_TIMEOUT,
          read_timeout: HTTP_READ_TIMEOUT
        )
      end

      def close_http_connections
        self.http_connections.each do |url, connection|
          connection.reset
        end
      end
    end

    attr_reader :client, :shared_header

    def initialize(client, shared_header)
      @client = client
      @shared_header = shared_header
      client.wsdl.namespaces["xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
      operations.each_key do |op|
        BingAdsRubySdk.logger.debug("Defining operation : #{op}")
        define_singleton_method(Utils.snakize(op)) do |body = false|
          request(op, body)
        end
      end
    end

    def operations
      client.wsdl.operations
    end

    private

    # Defining the http request
    def net_http_proc
      proc do |req|
        uri = URI(req.url)
        connection = BingAdsRubySdk::Service.connection(req.url)
        connection.post(
          path: uri.path,
          body: req.content,
          headers: req.headers,
        )
      end
    end

    def http_request(req)
      net_http_proc.call(req)
    end

    def parse_response(req, raw_response)
      raise BingAdsRubySdk::Errors::ServerError, raw_response if contains_error?(raw_response)

      client.response(req, raw_response.body).body_hash.tap do |b_h|
        BingAdsRubySdk.logger.debug(b_h)
        # FIXME : Is this necessary to transform an error hash in exceptions here ?
        # It might be a good idea to move that in the client instead.
        BingAdsRubySdk::Errors::ErrorHandler.parse_errors!(b_h)
      end
    end

    # Returns true if the response from the API is a Server error or a Client error
    def contains_error?(response)
      [
        Net::HTTPServerError,
        Net::HTTPClientError,
      ].any? { |http_error_class| response.class <= http_error_class }
    end

    def request(name, body)
      req = client.request(name)
      req.header.content(shared_header.content)
      req.body.content(body) if body

      BingAdsRubySdk.logger.debug(req.content)

      raw_response = http_request(req)
      BingAdsRubySdk.logger.debug(raw_response.body)
      parse_response(req, raw_response)
    end
  end
end
