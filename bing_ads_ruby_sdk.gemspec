# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bing_ads_ruby_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'bing_ads_ruby_sdk'
  spec.version       = BingAdsRubySdk::VERSION
  spec.authors       = %w[Sami Ben-yahia]
  spec.email         = %w[sami@effilab-local.com]

  spec.summary       = 'Bing Ads Ruby SDK'
  spec.description   = 'Higher level than lolsoap but just as fast !'
  spec.homepage      = 'https://github.com/Effilab/bing_ads_ruby_sdk'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency 'signet'
  spec.add_dependency 'lolsoap'
  spec.add_dependency 'excon'

  spec.add_development_dependency 'mock_redis'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'httplog'
end
