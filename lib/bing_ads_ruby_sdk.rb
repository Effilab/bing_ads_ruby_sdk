# frozen_string_literal: true
require 'time'
require 'lolsoap'

require 'bing_ads_ruby_sdk/version'
require 'bing_ads_ruby_sdk/api'
require 'bing_ads_ruby_sdk/wsdl_operation_wrapper'

module BingAdsRubySdk
  def self.logger
    @logger
  end

  def self.logger=(value)
    @logger = value
  end

  ATTRIBUTE_PREFIX = "@"
  TYPE_KEY = "@type"
  XSI_NAMESPACE_KEY = "xsi"

  def self.xsi_namespace_key
    XSI_NAMESPACE_KEY
  end

  def self.type_key
    TYPE_KEY
  end

  def self.attribute_prefix
    ATTRIBUTE_PREFIX
  end

  self.logger = Logger.new("log/soap.log").tap { |l| l.level = Logger::DEBUG }

  class ElementMismatch < StandardError; end

  LIB_DIR = __dir__
  CONF_PATH = File.join(__dir__, 'bing_ads_ruby_sdk', 'config')
end

def setup
  require 'dotenv/load'
  require 'byebug'

  store = ::BingAdsRubySdk::OAuth2::Store::FsStore.new(ENV.fetch('BING_TOKEN_NAME'))
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
  @cm = @auth.customer_management
  @cp = @auth.campaign_management
  @b = @auth.bulk
end