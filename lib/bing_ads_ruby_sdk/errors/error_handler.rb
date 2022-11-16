# frozen_string_literal: true

module BingAdsRubySdk
  module Errors
    # Parses the response from the API to raise errors if they are returned
    class ErrorHandler
      def initialize(response)
        @response = response
      end

      def call
        # Some operations don't return a response, for example:
        # https://msdn.microsoft.com/en-us/library/bing-ads-customer-management-deleteaccount.aspx
        return unless response.is_a? Hash
        raise fault_class, response if contains_error?
      end

      private

      attr_reader :response

      def contains_error?
        partial_error_keys.any? || contains_fault?
      end

      def contains_fault?
        (ERROR_KEYS & response.keys).any?
      end

      def fault_class
        ERRORS_MAPPING.fetch(hash_with_error.keys.first, BASE_FAULT)
      end

      def hash_with_error
        response[:detail] || partial_errors || {}
      end

      def partial_errors
        response.select { |key| partial_error_keys.include?(key) }
      end

      # Gets populated partial error keys from the response
      # @return [Array] array of symbols for keys in the response
      #   that are populated with errors
      def partial_error_keys
        @partial_error_keys ||= (PARTIAL_ERROR_KEYS & response.keys).reject do |key|
          response[key].nil? || response[key].is_a?(String)
        end
      end

      BASE_FAULT = BingAdsRubySdk::Errors::GeneralError
      PARTIAL_ERROR_KEYS = %i[partial_errors nested_partial_errors].freeze
      ERROR_KEYS = %i[faultcode error_code].freeze
      ERRORS_MAPPING = {
        api_fault_detail: BingAdsRubySdk::Errors::ApiFaultDetail,
        ad_api_fault_detail: BingAdsRubySdk::Errors::AdApiFaultDetail,
        editorial_api_fault_detail: BingAdsRubySdk::Errors::EditorialApiFaultDetail,
        api_batch_fault: BingAdsRubySdk::Errors::ApiBatchFault,
        api_fault: BingAdsRubySdk::Errors::ApiFault,
        nested_partial_errors: BingAdsRubySdk::Errors::NestedPartialError,
        partial_errors: BingAdsRubySdk::Errors::PartialError
      }.freeze
    end
  end
end
