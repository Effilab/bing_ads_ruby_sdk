# frozen_string_literal: true

module BingAdsRubySdk
  module Errors
    # Parses the response from the API to raise errors if they are returned
    class ErrorHandler
      BASE_FAULT = BingAdsRubySdk::Errors::StandardError

      class << self
        def parse_errors!(response)
          raise fault_class(response).new(response) if contains_error?(response)
        end

        def contains_error?(response)
          return unless response.is_a?(Hash)

          error_codes = %i[faultcode error_code]

          (error_codes & response.keys).any?
        end

        def fault_class(response)
          detail = response[:detail]

          return BASE_FAULT unless detail

          first_fault = detail.keys.first
          class_name = BingAdsRubySdk::Utils.camelize(first_fault.to_s)

          begin
            Object.const_get("BingAdsRubySdk::Errors::#{class_name}")
          rescue NameError
            BASE_FAULT
          end
        end
      end
    end
  end
end
