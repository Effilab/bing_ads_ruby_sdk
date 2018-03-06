require 'shared_helper'
require 'bing_ads_ruby_sdk/cache'

BingAdsRubySdk::Configuration::ENVIRONMENTS = %i[production].freeze
BingAdsRubySdk::Configuration::VERSIONS     = %i[v11].freeze

Dir.glob(File.join(__dir__, 'shared', '**', '*.rb')) { |f| require f }

BingAdsRubySdk::Cache.check
