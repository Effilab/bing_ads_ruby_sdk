# frozen_string_literal: true

BingAdsRubySdk.configure do |config|
  # conf.log = true
  # conf.logger.level = Logger::DEBUG
  # conf.pretty_print_xml = true

  ### to filter sensitive data before logging
  # conf.filters = ["AuthenticationToken", "DeveloperToken"]

  ### Optionally allow ActiveSupport::Notifications to be emitted by Excon.
  ### These notifications can then be sent on to your profiling system
  # conf.instrumentor = ActiveSupport::Notifications

  ### These are mandatory options that you must set:
  config.developer_token = ENV['BING_ADS_DEVELOPER_TOKEN']
  config.client_id = ENV['BING_ADS_CLIENT_ID']
  config.client_secret = ENV['BING_ADS_CLIENT_SECRET']
  config.filename = ENV['BING_ADS_FILENAME']
  config.customer_id = ENV['BING_ADS_CUSTOMER_ID']
  config.account_id = ENV['BING_ADS_ACCOUNT_ID']
end
