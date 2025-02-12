module BingAdsRubySdk
  module Services
    module Json
      class ApiError < StandardError
        ERROR_LIMIT = 2

        attr_reader :samples
        def initialize(errors)
          @samples = errors

          super(format_message(errors))
        end

        def format_message(errors)
          message = errors.take(ERROR_LIMIT).map { |error| format_error(error) }.join(", ")

          message = "#{message} (+#{errors.size - ERROR_LIMIT} not shown)" if errors.size > ERROR_LIMIT

          message
        end

        def format_error(error)
          index = error[:Index] ? "#{error[:Index]}: " : ""

          "#{index}#{error[:Code]} - #{error[:Message]}"
        end
      end

      class Base
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

          raise ApiError.new(response[error_key])
        end
      end
    end
    # Base class for the customer management and campaign management APIs
  end
end
