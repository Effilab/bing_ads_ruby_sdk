require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end
require 'shared_helper'

warn_level = $VERBOSE
$VERBOSE = nil
BingAdsRubySdk::Configuration::ENVIRONMENTS = %i[test].freeze
BingAdsRubySdk::Configuration::VERSIONS     = %i[v11].freeze
$VERBOSE = warn_level
