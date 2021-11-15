# frozen_string_literal: true

module BingAdsRubySdk
  module Preprocessors
    class Order
      def initialize(wsdl_wrapper, params)
        @wrapper = wsdl_wrapper
        @params = params
      end

      def call
        process(params, wrapper.request_namespace_type)
      end

      private

      attr_reader :wrapper, :params

      # NOTE: there is a potential for high memory usage here as we're using recursive method calling
      def process(obj, namespace_type)
        return obj unless obj.is_a?(Hash)

        allowed_attributes = wrapper.ordered_fields_hash(namespace_type)

        order(obj, allowed_attributes).tap do |ordered_hash|
          ordered_hash.each do |type_name, value|
            ordered_hash[type_name] = ordered_value(allowed_attributes, type_name, value)
          end
        end
      end

      def ordered_value(allowed_attributes, type_name, value)
        case value
        when Hash
          namespace_type = wrapper.namespace_and_type_from_name(allowed_attributes, type_name)
          process(value, namespace_type)
        when Array
          value.map do |elt|
            namespace_type = wrapper.namespace_and_type_from_name(allowed_attributes, type_name)
            process(elt, namespace_type)
          end
        else value
        end
      end

      def ordered_params(namespace_type)
        wrapper.ordered_fields_hash(namespace_type)
      end

      def order(hash, allowed_attributes)
        array = allowed_attributes.keys
        # basically order by index in reference array
        hash.sort_by { |k, _| array.index(wrapper.base_type_name(allowed_attributes, k)) || k.ord }.to_h
      end
    end
  end
end
