# frozen_string_literal: true

module BingAdsRubySdk
  module Preprocessors
    class Camelize

      def initialize(params)
        @params = params
      end

      def call
        process(@params)
      end

      private

      def process(obj)
        return obj unless obj.is_a?(Hash)

        obj.each_with_object({}) do |(k, v), h|
          case v
          when Hash then v = process(v)
          when Array then v = v.map {|elt| process(elt) }
          end
          h[transform_key(k.to_s)] = v
        end
      end

      def transform_key(key)
        if BLACKLIST.include?(key)
          key
        else
          camelize(key)
        end
      end

      def camelize(string)
        BingAdsRubySdk::StringUtils.camelize(string)
      end

      BLACKLIST = %w(long)
    end
  end
end