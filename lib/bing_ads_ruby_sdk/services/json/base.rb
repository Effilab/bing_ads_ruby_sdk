module BingAdsRubySdk
  module Services
    module Json
      class ApiError < StandardError; end

      class Base
        ERROR_LIMIT = 5

        # Request struct
        Request = Struct.new(:url, :headers, :content, keyword_init: true)
        def initialize(base_url:, headers:, auth_handler:)
          @client = BingAdsRubySdk::HttpClient
          @base_url = base_url
          @headers = headers
          @auth_handler = auth_handler
        end

        def post(operation, message)
          json = client.post(request(operation, message))

          response = JSON.parse(json, symbolize_names: true)

          catch_errors(response)

          response
        end

        def delete(operation, message)
          json = client.delete(request(operation, message))

          response = JSON.parse(json, symbolize_names: true)

          catch_errors(response)

          response
        end

        private

        attr_reader :client, :base_url, :headers, :auth_handler

        def request(operation, message)
          Request.new(
            url: "#{base_url}#{operation}",
            headers: headers.merge(
              authorization: "Bearer #{auth_handler.fetch_or_refresh}"
            ),
            content: format_message(message).to_json
          )
        end

        def format_message(message)
          BingAdsRubySdk::Preprocessors::Camelize.new(message).call
        end

        def catch_errors(response)
          catch_error(response, :BatchErrors)
          catch_error(response, :OperationErrors)
          catch_error(response, :PartialErrors)
        end

        def catch_error(response, error_key)
          return unless response[error_key]&.any?

          errors = response[error_key]
          message = errors.take(ERROR_LIMIT).map { |error| error[:Message] }.join(", ")

          raise ApiError, "#{message} ..."
        end
      end
    end
    # Base class for the customer management and campaign management APIs
  end
end
