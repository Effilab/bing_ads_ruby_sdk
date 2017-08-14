require 'bing_ads_ruby_sdk/version'
require 'bing_ads_ruby_sdk/api'
require 'logger'
require 'byebug'

# The logger is a module instance variable
# LolSoap callbacks are module instance variable
module BingAdsRubySdk
  @logger = Logger.new(STDERR, level: :info)

  class << self
    attr_accessor :logger
  end
end

require 'bing_ads_ruby_sdk/soap_callback_manager'

BingAdsRubySdk::SoapCallbackManager.register_callbacks