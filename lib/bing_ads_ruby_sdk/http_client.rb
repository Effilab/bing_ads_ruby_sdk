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

    class << self
      def post(request)
        uri = URI(request.url)
        conn = connection(request.url)
        conn.post(
          path: uri.path,
          body: request.content,
          headers: request.headers,
        )
      end

      def close_http_connections
        self.http_connections.each do |url, connection|
          connection.reset
        end
      end

      private

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
          read_timeout: HTTP_READ_TIMEOUT,
          ssl_version: :TLSv1_2,
          ciphers: "TLSv1.2:!aNULL:!eNULL",
        )
      end
    end
  end
end
