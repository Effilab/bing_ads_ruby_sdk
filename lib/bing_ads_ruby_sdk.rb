# frozen_string_literal: true

require "time"
require "lolsoap"

require "bing_ads_ruby_sdk/version"
require "bing_ads_ruby_sdk/configuration"
require "bing_ads_ruby_sdk/api"
require "bing_ads_ruby_sdk/string_utils"
require "bing_ads_ruby_sdk/railtie" if defined?(Rails)

module BingAdsRubySdk
  def self.config
    @configuration ||= BingAdsRubySdk::Configuration.new
  end

  def self.configure
    yield(config)
  end

  def self.log(level, *args, &block)
    return unless config.log
    config.logger.send(level, *args, &block)
  end

  def self.root_path
    ROOT_PATH
  end

  def self.type_key
    TYPE_KEY
  end

  TYPE_KEY = "@type"
  ROOT_PATH = File.join(__dir__, "..")
end
