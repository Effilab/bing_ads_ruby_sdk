require "simplecov"
require "byebug"
require "vcr"
require "webmock/rspec"

begin
  require "dotenv/load"
rescue LoadError
  puts "Unable to load .env file, resuming..."
end

SimpleCov.start do
  add_filter "/spec/"
end

require "bing_ads_ruby_sdk"
require "uri"

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path("fixtures/vcr_cassettes", __dir__)
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = {
    match_requests_on: %i[method uri],
    record: ENV.fetch("VCR_RECORD", :none).to_sym
  }
  config.filter_sensitive_data("[BING_DEVELOPER_TOKEN]") { ENV["BING_DEVELOPER_TOKEN"] }
  config.filter_sensitive_data("[BING_CLIENT_ID]") { ENV["BING_CLIENT_ID"] }
  config.filter_sensitive_data("[BING_CLIENT_SECRET]") { ENV["BING_CLIENT_SECRET"] }
  config.filter_sensitive_data("[BING_ACCESS_TOKEN]") { ENV["BING_ACCESS_TOKEN"] }
  config.filter_sensitive_data("[BING_REFRESH_TOKEN]") { ENV["BING_REFRESH_TOKEN"] }
  config.filter_sensitive_data("[BING_CUSTOMER_ID]") { ENV["BING_SANDBOX_CUSTOMER_ID"] }
  config.filter_sensitive_data("[BING_ACCOUNT_ID]") { ENV["BING_SANDBOX_ACCOUNT_ID"] }
  config.before_record do |interaction|
    interaction.request.headers["Authorization"] = ["Bearer [BING_ACCESS_TOKEN]"] if interaction.request.headers["Authorization"]

    uri = begin
      URI.parse(interaction.request.uri.to_s)
    rescue
      nil
    end
    host = uri&.host&.downcase
    allowed_hosts = ["login.microsoftonline.com"]

    if allowed_hosts.include?(host)
      interaction.request.body = interaction.request.body.to_s.gsub(/refresh_token=[^&]+/, "refresh_token=[BING_REFRESH_TOKEN]")
        .gsub(/client_secret=[^&]+/, "client_secret=[BING_CLIENT_SECRET]")
      interaction.response.body = interaction.response.body.to_s.gsub(/("access_token"\s*:\s*")[^"]+/, '\\1[BING_ACCESS_TOKEN]')
    end
  end
end

Dir[File.join(BingAdsRubySdk.root_path, "spec", "support", "**", "*.rb")].sort.each { |f| require f }
Dir[File.join(BingAdsRubySdk.root_path, "log", "*.log")].sort.each do |log_file|
  File.open(log_file, "w") { |f| f.truncate(0) }
end

BingAdsRubySdk.configure do |conf|
  conf.log = true
  conf.logger.level = Logger::DEBUG
  conf.pretty_print_xml = true
  conf.filters = ["AuthenticationToken", "DeveloperToken", "CustomerId", "CustomerAccountId"]
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
