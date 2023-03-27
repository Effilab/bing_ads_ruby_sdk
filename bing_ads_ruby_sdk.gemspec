lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bing_ads_ruby_sdk/version"

Gem::Specification.new do |spec|
  spec.name = "bing_ads_ruby_sdk"
  spec.required_ruby_version = ">= 2.3"

  spec.version = BingAdsRubySdk::VERSION
  spec.authors = %w[Effilab developers]
  spec.email = %w[dev@effilab.com]

  spec.summary = "Bing Ads Ruby SDK"
  spec.description = "Bing Ads Api Wrapper"
  spec.homepage = "https://github.com/Effilab/bing_ads_ruby_sdk"
  spec.license = "MIT"

  spec.files = Dir[
    "bing_ads_ruby_sdk.gemspec",
    "changelog.md",
    "README.md",
    "Gemfile",
    "Rakefile",
    "LICENSE.txt",
    "{bin,lib,tasks}/**/*"
  ]
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "signet"
  spec.add_runtime_dependency "excon", ">= 0.62.0"
  spec.add_runtime_dependency "lolsoap", ">=0.9.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4.1"
end
