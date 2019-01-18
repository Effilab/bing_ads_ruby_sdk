require 'simplecov'
require "benchmark"
require 'byebug'
require 'bing_ads_ruby_sdk'
require 'dotenv/load'

Dir[File.join(BingAdsRubySdk.root_path, "spec", "support", "**", "*.rb")].each { |f| require f }
Dir[File.join(BingAdsRubySdk.root_path, "log", "*.log")].each do |log_file|
  File.open(log_file, 'w') { |f| f.truncate(0) }
end

SimpleCov.start do
  add_filter '/spec/'
end

BingAdsRubySdk.configure do |conf|
  conf.log = true
  conf.logger.level = Logger::DEBUG
  conf.pretty_print_xml = true
  conf.filters = ["AuthenticationToken", "DeveloperToken", "CustomerId", "CustomerAccountId"]
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end