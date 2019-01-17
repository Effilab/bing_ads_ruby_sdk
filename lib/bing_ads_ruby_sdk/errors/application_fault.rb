# frozen_string_literal: true

module BingAdsRubySdk
  # TODO: split these error classes to their own file
  module Errors
    # Base exception class for reporting API errors
    class GeneralError < ::StandardError
      attr_accessor :raw_response, :message

      def initialize(response)
        @raw_response = response

        code = response[:error_code] || 'Bing Ads API error'

        message = response[:message] ||
                    response[:faultstring] ||
                      'See exception details for more information.'

        @message = format_message(code, message)
      end

      # Format the message separated by hyphen if
      # there is a code and a message
      def format_message(code, message)
        [code, message].compact.join(' - ')
      end
    end

    # Base exception class for handling errors where the detail is supplied
    class ApplicationFault < GeneralError
      def initialize(response)
        super

        populate_error_lists
      end

      def message
        error_list = all_errors
        return @message if error_list.empty?

        first_message = first_error_message(error_list)
        if error_list.count > 1
          "API raised #{ error_list.count } errors, including: #{first_message}"
        else
          first_message
        end
      end

      private

      def populate_error_lists
        self.class.error_lists.each do |key|
          instance_variable_set("@#{key}", array_wrap(fault_hash[key]))
        end
      end

      def all_errors
        self.class.error_lists.flat_map do |list_name|
          list = send(list_name)

          # Call sometimes returns an empty string instead of
          # nil for empty lists
          list.nil? || list.empty? ? nil : list
        end.compact
      end

      # The fault hash from the API response detail element
      # @return [Hash] containing the fault information if provided
      # @return [Hash] empty hash if no fault information
      def fault_hash
        raw_response[:detail][fault_key] || {}
      end

      # The fault key that corresponds to the inherited class
      # @return [Symbol] the fault key
      def fault_key
        class_name = self.class.name.split('::').last
        BingAdsRubySdk::StringUtils.snakize(class_name).to_sym
      end

      def first_error_message(error_list)
        error = error_list.first.values.first
        format_message(error[:error_code], error[:message])
      end

      def array_wrap(value)
        case value
        when Array then value
        when nil, "" then []
        else
          [value]
        end
      end

      class << self
        def error_lists=(value)
          @error_lists = value
        end

        def error_lists
          @error_lists ||= []
        end

        def define_error_lists(*error_list_array)
          self.error_lists += error_list_array

          error_list_array.each { |attr| attr_accessor attr }
        end
      end
    end

    # Base class for handling partial errors
    class PartialErrorBase < ApplicationFault
      # The parent hash for this type of error is the root of the response
      def fault_hash
        raw_response[fault_key] || {}
      end

      # Gets the first error message in the list. This is
      # overridden because partial errors are structured differently
      # to application faults
      # @return [Hash] containing the details of the error
      def first_error_message(error_list)
        error = error_list.first
        format_message(error[:error_code], error[:message])
      end
    end

    class PartialError < PartialErrorBase
      define_error_lists :batch_error

      def fault_key
        :partial_errors
      end
    end

    class NestedPartialError < PartialErrorBase
      define_error_lists :batch_error_collection

      def fault_key
        :nested_partial_errors
      end
    end

    # For handling API errors of the same name.
    # Documentation:
    # https://msdn.microsoft.com/en-gb/library/bing-ads-overview-adapifaultdetail.aspx
    class AdApiFaultDetail < ApplicationFault
      define_error_lists :errors
    end

    # For handling API errors of the same name.
    # Documentation:
    # https://msdn.microsoft.com/en-gb/library/bing-ads-overview-apifaultdetail.aspx
    class ApiFaultDetail < ApplicationFault
      define_error_lists :batch_errors, :operation_errors
    end

    # For handling API errors of the same name.
    # Documentation:
    # https://msdn.microsoft.com/en-gb/library/bing-ads-overview-editorialapifaultdetail.aspx
    class EditorialApiFaultDetail < ApplicationFault
      define_error_lists :batch_errors, :editorial_errors, :operation_errors
    end

    # For handling API errors of the same name.
    # Documentation:
    # https://msdn.microsoft.com/en-gb/library/bing-ads-apibatchfault-customer-billing.aspx
    class ApiBatchFault < ApplicationFault
      define_error_lists :batch_errors, :operation_errors
    end

    # For handling API errors of the same name.
    # Documentation:
    # https://msdn.microsoft.com/en-gb/library/bing-ads-apifault-customer-billing.aspx
    class ApiFault < ApplicationFault
      define_error_lists :operation_errors
    end
  end
end
