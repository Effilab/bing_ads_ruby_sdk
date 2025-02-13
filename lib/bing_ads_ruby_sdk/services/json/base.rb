

module BingAdsRubySdk
  module Services
    module Json
      # Base class for the customer management and campaign management APIs
      class Base
        Request = Struct.new(:url, :headers, :content, keyword_init: true)
        def initialize(base_url:, headers:, auth_handler:)
          @client = BingAdsRubySdk::HttpClient
          @base_url = base_url
          @headers = headers
          @auth_handler = auth_handler
        end

        # @param operation [String] API operation
        #   Translates to the URL path appended to the base URL
        # @param message [Hash] the message to send to the API
        def post(operation, message)
          json = client.post(request(operation, message))

          response = JSON.parse(json, symbolize_names: true)

          catch_errors(response)

          response
        end

        # @param operation [String] API operation
        #   Translates to the URL path appended to the base URL
        # @param message [Hash] the message to send to the API
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

        def catch_error(response, category)
          return unless response[category]&.any?

          raise ApiError.new(category, response[category])
        end
      end
    end
  end
end
