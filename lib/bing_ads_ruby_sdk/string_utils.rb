# frozen_string_literal: true

module BingAdsRubySdk
  module StringUtils
    def self.camelize(string)
      string.split(UNDERSCORE).collect! { |w| w.capitalize }.join
    end

    def self.snakize(string)
      raise "Unexpected string length : #{string.length} for string '#{string[0..200]}...'" if string.length > 1000

      string.gsub(MULTIPLE_CAPSREGEX, MATCHING_PATTERN)
        .gsub(SPLIT_REGEX, MATCHING_PATTERN)
        .tr("-", "_")
        .downcase
        .to_sym
    end

    UNDERSCORE = "_"
    MULTIPLE_CAPSREGEX = /([A-Z]+)([A-Z][a-z])/
    SPLIT_REGEX = /([a-z\d])([A-Z])/
    MATCHING_PATTERN = '\1_\2'
  end
end
