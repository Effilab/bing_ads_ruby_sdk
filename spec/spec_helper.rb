require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end
require 'shared_helper'

warn_level = $VERBOSE
$VERBOSE = nil
BingAdsRubySdk::Configuration::ENVIRONMENTS = %i[test].freeze
BingAdsRubySdk::Configuration::VERSIONS     = %i[v11].freeze
BingAdsRubySdk::Configuration::CACHE_BASE   = Dir.tmpdir
BingAdsRubySdk::Configuration::CONF_PATH    = File.join(__dir__, 'fixtures')
$VERBOSE = warn_level
