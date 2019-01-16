# frozen_string_literal: true

module BingAdsRubySdk
  module Errors
    # Parses the response from the API to raise errors if they are returned
    class ErrorHandler
      BASE_FAULT = BingAdsRubySdk::Errors::GeneralError
      PARTIAL_ERROR_KEYS = %i[partial_errors nested_partial_errors].freeze

      class << self
        def parse_errors!(response)
          # Some operations don't return a response, for example:
          # https://msdn.microsoft.com/en-us/library/bing-ads-customer-management-deleteaccount.aspx
          return unless response.is_a? Hash
          raise fault_class(response).new(response) if contains_error?(response)
        end

        def contains_error?(response)
          contains_partial_errors?(response) ||
            contains_fault?(response)
        end

        def contains_partial_errors?(response)
          partial_error_keys(response).any?
        end

        def contains_fault?(response)
          error_keys = %i[faultcode error_code]

          (error_keys & response.keys).any?
        end

        def fault_class(response)
          hash_with_error = response[:detail] || partial_errors(response)

          return BASE_FAULT unless hash_with_error

          error = hash_with_error.keys.first

          begin
            Object.const_get("BingAdsRubySdk::Errors::#{klass_name(error)}")
          rescue NameError
            BASE_FAULT
          end
        end

        def partial_errors(response)
          keys = partial_error_keys(response)
          response.select {|key| keys.include?(key)}
        end

        def klass_name(key)
          key_string = key.to_s

          # Partial errors are stored in a key with a plural name,
          # but exception classes are named in the singular by convention
          key_string = key_string.gsub(/s$/, '') if PARTIAL_ERROR_KEYS.include?(key)

          BingAdsRubySdk::Utils.camelize(key_string)
        end

        # Gets populated partial error keys from the response
        # @return [Array] array of symbols for keys in the response
        #   that are populated with errors
        def partial_error_keys(response)
          existing_keys = (PARTIAL_ERROR_KEYS & response.keys)

          existing_keys.reject do |key|
            response[key].nil? || response[key].is_a?(String)
          end
        end
      end
    end
  end
end
