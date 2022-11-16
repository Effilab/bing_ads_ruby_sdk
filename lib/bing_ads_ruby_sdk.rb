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

  def self.create_token
    # This will only be done depending on the expiration set for the client secret
    # 1. create app, https://learn.microsoft.com/en-us/advertising/guides/authentication-oauth-register?view=bingads-13
    # 2. get client id on the dashboard
    # 3. create secret, client_secret is actually client_value
    auth = BingAdsRubySdk::OAuth2::AuthorizationHandler.new(
      developer_token: BingAdsRubySdk.config.developer_token,
      client_id: BingAdsRubySdk.config.client_id,
      client_secret: BingAdsRubySdk.config.client_secret,
      store: store
    )
    puts "Go to #{auth.code_url}."
    puts "You will be redirected to a URL at the end. Paste it here in the console and press enter"

    full_url = $stdin.gets.chomp
    auth.fetch_from_url(full_url)

    puts "Written to store"
  end

  def self.client
    client = BingAdsRubySdk::Api.new(
      oauth_store: store,
      developer_token: BingAdsRubySdk.config.developer_token,
      client_id: BingAdsRubySdk.config.client_id,
      client_secret: BingAdsRubySdk.config.client_secret
    )
    # customer id and account id are on the main campaign url
    # https://ui.ads.microsoft.com/campaign/vnext/campaigns?aid=xxx&cid=xxx&uid=xxx
    client.set_customer(customer_id: BingAdsRubySdk.config.customer_id,
                        account_id: BingAdsRubySdk.config.account_id)
    client
  end

  def self.store
    @store ||= ::BingAdsRubySdk::OAuth2::FsStore.new(FILENAME)
  end

  TYPE_KEY = "@type"
  ROOT_PATH = File.join(__dir__, "..")
end
