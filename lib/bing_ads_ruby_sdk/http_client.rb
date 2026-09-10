# frozen_string_literal: true

require "net/http"
require "excon"
require "securerandom"

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

      def put(request)
        uri = URI(request.url)
        conn = connection("#{uri.scheme}://#{uri.host}")
        raw_response = conn.put(
          path: uri.path,
          body: request.content,
          headers: request.headers
        )

        raw_response.body
      end

      def post_multipart(url:, headers:, content:, filename:)
        uri = URI(url)
        boundary = "----BingAdsRubySdk#{SecureRandom.hex(16)}"
        body = multipart_body(boundary, content, filename)
        raw_response = connection("#{uri.scheme}://#{uri.host}").post(
          path: uri.request_uri,
          body: body,
          headers: headers.merge(
            "Content-Type" => "multipart/form-data; boundary=#{boundary}"
          )
        )

        raw_response.body
      end

      def get(url, stream: false)
        uri = URI(url)
        return get_stream(uri) if stream

        raw_response = connection("#{uri.scheme}://#{uri.host}").get(
          path: uri.request_uri
        )

        raw_response.body
      end

      def get_stream(uri)
        Enumerator.new do |chunks|
          connection("#{uri.scheme}://#{uri.host}").get(
            path: uri.request_uri,
            response_block: ->(chunk, *) { chunks << chunk }
          )
        end
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

      def multipart_body(boundary, content, filename)
        "--#{boundary}\r\n" \
        "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n" \
        "Content-Type: text/csv\r\n\r\n" \
        "#{content}\r\n" \
        "--#{boundary}--\r\n"
      end
    end
  end
end
