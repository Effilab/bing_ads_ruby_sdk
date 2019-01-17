# frozen_string_literal: true

module BingAdsRubySdk
  module Postprocessors
    class Snakize

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
          h[snakize(k)] = v
        end
      end

      def snakize(string)
        BingAdsRubySdk::StringUtils.snakize(string)
      end
    end
  end
end