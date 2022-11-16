# frozen_string_literal: true

module BingAdsRubySdk
  module StringUtils
    def self.camelize(string)
      string.split(UNDERSCORE).collect!(&:capitalize).join
    end

    def self.snakize(string)
      string.gsub(MULTIPLE_CAPSREGEX, MATCHING_PATTERN)
            .gsub(SPLIT_REGEX, MATCHING_PATTERN)
            .tr('-', '_')
            .downcase
            .to_sym
    end

    UNDERSCORE = '_'
    MULTIPLE_CAPSREGEX = /([A-Z]+)([A-Z][a-z])/.freeze
    SPLIT_REGEX = /([a-z\d])([A-Z])/.freeze
    MATCHING_PATTERN = '\1_\2'
  end
end
