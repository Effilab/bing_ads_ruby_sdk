# frozen_string_literal: true

require 'net/http'
require 'excon'

module BingAdsRubySdk
  class HttpClient
    @http_connections = {}
    HTTP_OPEN_TIMEOUT = 10
    HTTP_READ_TIMEOUT = 20
    HTTP_RETRY_COUNT_ON_TIMEOUT = 2
    HTTP_INTERVAL_RETRY_COUNT_ON_TIMEOUT = 1
    HTTP_ERRORS = [Net::HTTPServerError, Net::HTTPClientError].freeze
    CONNECTION_SETTINGS = {
      persistent: true,
      tcp_nodelay: true,
      retry_limit: HTTP_RETRY_COUNT_ON_TIMEOUT,
      idempotent: true,
      retry_interval: HTTP_INTERVAL_RETRY_COUNT_ON_TIMEOUT,
      connect_timeout: HTTP_OPEN_TIMEOUT,
      read_timeout: HTTP_READ_TIMEOUT,
      ssl_version: :TLSv1_2,
      ciphers: 'TLSv1.2:!aNULL:!eNULL'
    }.freeze

    class << self
      def post(request)
        uri = URI(request.url)
        conn = connection(request.url)
        raw_response = conn.post(
          path: uri.path,
          body: request.content,
          headers: request.headers
        )

        if contains_error?(raw_response)
          BingAdsRubySdk.log(:warn) { BingAdsRubySdk::LogMessage.new(raw_response.body).to_s }
          raise BingAdsRubySdk::Errors::ServerError, raw_response.body
        else
          BingAdsRubySdk.log(:debug) { BingAdsRubySdk::LogMessage.new(raw_response.body).to_s }
        end

        raw_response.body
      end

      def close_http_connections
        http_connections.each_value(&:reset)
      end

      protected

      attr_reader :http_connections

      def contains_error?(response)
        HTTP_ERRORS.any? { |http_error_class| response.class <= http_error_class }
      end

      def connection_settings
        CONNECTION_SETTINGS.tap do |args|
          instrumentor = BingAdsRubySdk.config.instrumentor
          args[:instrumentor] = instrumentor if instrumentor
        end
      end

      def connection(host)
        http_connections[host] ||= Excon.new(
          host,
          connection_settings
        )
      end
    end
  end
end
