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
    attr_accessor :abstract_callback, :request_callback, :response_callback
  end
end

# Instanciate the callbacks in the order I want them triggered
BingAdsRubySdk.abstract_callback = LolSoap::Callbacks.new
BingAdsRubySdk.request_callback  = LolSoap::Callbacks.new
BingAdsRubySdk.response_callback = LolSoap::Callbacks.new

require 'bing_ads_ruby_sdk/soap_callback_manager'

BingAdsRubySdk::SoapCallbackManager.register_callbacks