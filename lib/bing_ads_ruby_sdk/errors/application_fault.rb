# frozen_string_literal: true

module BingAdsRubySdk
  # TODO: split these error classes to their own file
  module Errors
    # Base exception class for reporting API errors
    class StandardError < ::StandardError
      attr_accessor :raw_response, :message

      def initialize(response)
        @raw_response = response

        error_details = response[:message] || "See exception details for more information."
        @message = "Bing Ads API error. #{ error_details }"
      end
    end

    # Base exception class for handling errors where the detail is supplied
    class ApplicationFault < StandardError
      # The fault hash from the API response detail element
      # @return [Hash] containing the fault information if provided
      # @return [Hash] empty hash if no fault information
      def fault_hash
        @raw_response[:detail][fault_key] || {}
      end

      # The fault key that corresponds to the inherited class
      # @return [Symbol] the fault key
      def fault_key
        class_name = self.class.name.split('::').last
        BingAdsRubySdk::Utils.snakize(class_name).to_sym
      end
    end

    class AdApiFaultDetail < ApplicationFault
      attr_accessor :errors

      def initialize(response)
        super
        @errors = fault_hash[:errors]
      end

      def error_message
        @errors.first
      end
    end

    class ApiFaultDetail < ApplicationFault
      attr_accessor :batch_errors
      attr_accessor :operation_errors

      def initialize(response)
        super

        @batch_errors = fault_hash[:batch_errors]
        @operation_errors = fault_hash[:operation_errors]
      end
    end

    class EditorialApiFaultDetail < ApplicationFault
      attr_accessor :batch_errors
      attr_accessor :editorial_errors
      attr_accessor :operation_errors

      def initialize(response)
        super
        @batch_errors =     fault_hash[:batch_errors]
        @editorial_errors = fault_hash[:editorial_errors]
        @operation_errors = fault_hash[:operation_errors]
      end
    end

    class ApiBatchFault < ApplicationFault
      attr_accessor :batch_errors
      attr_accessor :operation_errors

      def initialize(response)
        super
        @batch_errors =     fault_hash[:batch_errors]
        @operation_errors = fault_hash[:operation_errors]
      end
    end

    class ApiFault < ApplicationFault
      attr_accessor :operation_errors

      def initialize(response)
        super
        @operation_errors = fault_hash[:operation_errors]
      end
    end
  end
end
