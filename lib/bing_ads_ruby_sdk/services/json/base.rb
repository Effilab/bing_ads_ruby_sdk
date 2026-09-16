require "bing_ads_ruby_sdk/errors/errors"
require "bing_ads_ruby_sdk/postprocessors/snakize"

module BingAdsRubySdk
  module Services
    module Json
      # Base class for the customer management and campaign management APIs
      class Base
        Request = Struct.new(:url, :headers, :content)
        # Per learn.microsoft.com/en-us/advertising docs, JSON responses only
        # ever expose these fields (never SOAP's detail-wrapped BatchErrors/
        # OperationErrors); `errors` covers Bulk's GetBulkUploadStatus.Errors.
        FAULT_CLASSES = {
          partial_errors: BingAdsRubySdk::Errors::PartialError,
          nested_partial_errors: BingAdsRubySdk::Errors::NestedPartialError,
          errors: BingAdsRubySdk::Errors::AdApiFaultDetail
        }.freeze

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
          respond(client.post(request(operation, message)))
        end

        # @param operation [String] API operation
        #   Translates to the URL path appended to the base URL
        # @param message [Hash] the message to send to the API
        def delete(operation, message)
          respond(client.delete(request(operation, message)))
        end

        def put(operation, message)
          respond(client.put(request(operation, message)))
        end

        private

        attr_reader :client, :base_url, :headers, :auth_handler

        def respond(json)
          response = snakize(JSON.parse(json, symbolize_names: true))

          catch_errors(response)

          response
        end

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

        def snakize(response)
          BingAdsRubySdk::Postprocessors::Snakize.new(response).call
        end

        def catch_errors(response)
          category = FAULT_CLASSES.keys.find { |key| response[key]&.any? }
          return unless category

          raise FAULT_CLASSES.fetch(category), response
        end
      end
    end
  end
end
