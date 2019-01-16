# frozen_string_literal: true

module BingAdsRubySdk
  module Postprocessors
    class CastLongArrays

      def initialize(params)
        @params = params
      end

      def call
        process(@params)
      end

      private

      def process(obj)
        return unless obj.is_a?(Hash)

        obj.each do |k, v|
          case v
          when Hash
            if v[:long].is_a?(Array)
              obj[k] = v[:long].map(&:to_i)
            else
              process(v)
            end
          when Array
            v.each {|elt| process(elt) }
          end
        end
      end
    end
  end
end