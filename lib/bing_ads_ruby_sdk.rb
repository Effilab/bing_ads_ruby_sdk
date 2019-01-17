# frozen_string_literal: true
require 'time'
require 'lolsoap'

require 'bing_ads_ruby_sdk/version'
require 'bing_ads_ruby_sdk/configuration'
require 'bing_ads_ruby_sdk/api'
require 'bing_ads_ruby_sdk/string_utils'

module BingAdsRubySdk
  def self.config
    @configuration
  end

  def self.configure
    @configuration ||= BingAdsRubySdk::Configuration.new
    yield(config)
  end

  def self.log(level, *args, &block)
    return unless config.log
    config.logger.send(level, *args, &block)
  end
  def self.xsi_namespace_key
    XSI_NAMESPACE_KEY
  end

  def self.type_key
    TYPE_KEY
  end

  def self.root_path
    ROOT_PATH
  end

  TYPE_KEY = "@type"
  XSI_NAMESPACE_KEY = "xsi"
  ROOT_PATH = File.join(__dir__,'..')
end

def setup
  require 'dotenv/load'
  require 'byebug'

  store = ::BingAdsRubySdk::OAuth2::FsStore.new(ENV.fetch('BING_TOKEN_NAME'))
  @auth = BingAdsRubySdk::Api.new(
    oauth_store: store,
    credentials: {
      developer_token: ENV.fetch('BING_DEVELOPER_TOKEN'),
      client_id: ENV.fetch('BING_CLIENT_ID')
    }
  )
  @auth.set_customer({
    id: ENV.fetch('BING_CUSTOMER_ID'),
    account_id: ENV.fetch('BING_ACCOUNT_ID')
  })
  BingAdsRubySdk.configure do |conf|
    conf.log = true
    conf.logger.level = Logger::DEBUG
    conf.filters = ["AuthenticationToken", "DeveloperToken"]
  end
  @cm = @auth.customer_management
  @cp = @auth.campaign_management
  @b = @auth.bulk
end