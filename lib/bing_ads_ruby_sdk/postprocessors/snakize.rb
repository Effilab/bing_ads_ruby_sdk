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

      def self.call(string)
        string.gsub(MULTIPLE_CAPSREGEX, MATCHING_PATTERN)
              .gsub(SPLIT_REGEX, MATCHING_PATTERN)
              .tr('-', '_')
              .downcase
              .to_sym
      end

      private

      MULTIPLE_CAPSREGEX = /([A-Z]+)([A-Z][a-z])/
      SPLIT_REGEX = /([a-z\d])([A-Z])/
      MATCHING_PATTERN = '\1_\2'

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
        self.class.call(string)
      end
    end
  end
end