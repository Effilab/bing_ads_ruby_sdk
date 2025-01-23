# frozen_string_literal: true

require "net/http"
require "excon"

module BingAdsRubySdk
  class HttpClient
    @http_connections = {}
    HTTP_OPEN_TIMEOUT = 10
    HTTP_READ_TIMEOUT = 20
    HTTP_RETRY_COUNT_ON_TIMEOUT = 2
    HTTP_INTERVAL_RETRY_COUNT_ON_TIMEOUT = 1
    CONNECTION_SETTINGS = {
      persistent: true,
      tcp_nodelay: true,
      retry_limit: HTTP_RETRY_COUNT_ON_TIMEOUT,
      idempotent: true,
      retry_interval: HTTP_INTERVAL_RETRY_COUNT_ON_TIMEOUT,
      connect_timeout: HTTP_OPEN_TIMEOUT,
      read_timeout: HTTP_READ_TIMEOUT,
      ssl_version: :TLSv1_2,
      ciphers: "TLSv1.2:!aNULL:!eNULL"
    }

    class << self
      def post(request)
        uri = URI(request.url)
        conn = connection("#{uri.scheme}://#{uri.host}")
        raw_response = conn.post(
          path: uri.path,
          body: request.content,
          headers: request.headers
        )

        raw_response.body
      end

      def delete(request)
        uri = URI(request.url)
        conn = connection("#{uri.scheme}://#{uri.host}")
        raw_response = conn.delete(
          path: uri.path,
          body: request.content,
          headers: request.headers
        )

        raw_response.body
      end

      def close_http_connections
        http_connections.values.each do |connection|
          connection.reset
        end

        http_connections.clear
      end

      protected

      attr_reader :http_connections

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
