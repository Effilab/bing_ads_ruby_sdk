require 'simplecov'
require "benchmark"

SimpleCov.start do
  add_filter '/spec/'
end
require 'shared_helper'
require 'httplog'
require 'fileutils'
require 'mock_redis'

warn_level = $VERBOSE
$VERBOSE = nil

BingAdsRubySdk::Configuration::ENVIRONMENTS = %i[test].freeze
$VERBOSE = warn_level

log_path = "log"
log_file = "#{log_path}/test.log"
FileUtils.mkdir_p(log_path)
File.open(log_file, 'w') { |f| f.write('') }

BingAdsRubySdk.logger = Logger.new(File.open(log_file, 'w'))
BingAdsRubySdk.logger.level = :debug

# https://github.com/trusche/httplog
# We need to initialize it early so we use 00_httplog.rb name

HttpLog.configure do |config|
  # Enable or disable all logging
  # Disable for production
  config.enabled = true

  # You can assign a different logger
  config.logger = Logger.new("log/http.log")

  # I really wouldn't change this...
  config.severity = Logger::Severity::DEBUG

  # Tweak which parts of the HTTP cycle to log...
  config.log_connect   = true
  config.log_request   = true
  config.log_headers   = true
  config.log_data      = false

  config.log_status    = true
  config.log_response  = false
  # Display timing for every request:
  config.log_benchmark = true

  # ...or log all request as a single line by setting this to `true`
  # config.compact_log = true

  # Prettify the output - see below
  config.color = true

  # Limit logging based on URL patterns
  config.url_whitelist_pattern = /.*/
  config.url_blacklist_pattern = nil
end
