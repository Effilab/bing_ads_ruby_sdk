# frozen_string_literal: true

require 'bing_ads_ruby_sdk/preprocessors/camelize'
require 'bing_ads_ruby_sdk/preprocessors/order'
require 'bing_ads_ruby_sdk/postprocessors/snakize'
require 'bing_ads_ruby_sdk/postprocessors/cast_long_arrays'


module BingAdsRubySdk
  module Services
    class Base

      def initialize(soap_client)
        @soap_client = soap_client
      end

      def call(operation_name, message = {})
        camelized_name = BingAdsRubySdk::StringUtils.camelize(operation_name.to_s)
        response = soap_client.call(
          camelized_name,
          preprocess(message, camelized_name),
        )
        postprocess(response)
      end

      def call_wrapper(action, message, *response_nesting)
        response = call(action, message)
        wrap_array(dig_response(response, response_nesting))
      end

      def self.service
        raise 'implement me'
      end

      private

      attr_reader :soap_client

      def preprocess(message, operation_name)
        order(
          soap_client.wsdl_wrapper(operation_name),
          camelize(message)
        )
      end

      def postprocess(message)
        cast_long_arrays(
          snakize(message)
        )
      end

      def order(wrapper, hash)
        ::BingAdsRubySdk::Preprocessors::Order.new(wrapper, hash).call
      end

      def camelize(hash)
        ::BingAdsRubySdk::Preprocessors::Camelize.new(hash).call
      end

      def snakize(hash)
        ::BingAdsRubySdk::Postprocessors::Snakize.new(hash).call
      end

      def cast_long_arrays(hash)
        ::BingAdsRubySdk::Postprocessors::CastLongArrays.new(hash).call
      end

      def dig_response(response, keys)
        response.dig(*keys)
      rescue StandardError => e
        nil
      end

      def wrap_array(arg)
        case arg
        when Array then arg
        when nil, "" then []
        else [arg]
        end
      end
    end
  end
end
