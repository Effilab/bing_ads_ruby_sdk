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

      # NOTE: there is a potential for high memory usage here as we're using recursive method calling
      def process(obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(k, v), h|
            h[snakize(k)] = process(v)
          end
        when Array
          obj.map { |elt| process(elt) }
        else
          obj
        end
      end

      def snakize(string)
        BingAdsRubySdk::StringUtils.snakize(string.to_s)
      end
    end
  end
end
