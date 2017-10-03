# frozen_string_literal: true

require 'bing_ads_ruby_sdk/version'
require 'bing_ads_ruby_sdk/api'
require 'logger'

# The logger is a module instance variable
module BingAdsRubySdk
  @logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }

  class << self
    attr_accessor :logger
  end
end
