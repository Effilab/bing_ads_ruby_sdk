require 'shared_helper'
require 'bing_ads_ruby_sdk/cache'

Dir.glob(File.join(__dir__, 'shared', '**', '*.rb')) { |f| require f }

BingAdsRubySdk::Cache.build
BingAdsRubySdk::Cache.check
