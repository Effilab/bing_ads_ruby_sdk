# require 'lolsoap'
require 'YAML'
require 'bing_ads_ruby_sdk/service'
# require 'open-uri'

module BingAdsRubySdk
  class Api
    attr_reader :services

    def initialize(version: :v11, environment: :production, credentials: {})
      bing_ads_callbacks = LolSoap::Callbacks.new
      bing_ads_callbacks.for('hash_params.before_build') << lambda do |args, node, type|
        matcher = type.elements.keys.map { |name| name.tr('_', '').downcase }
        args.each do |h|
          found_at = matcher.index(h[:name].tr('_', '').downcase)
          h[:name] = type.elements.keys[found_at] if found_at
        end
        args.sort_by! { |h| type.elements.keys.index(h[:name]) || 1 / 0.0 }
      end

      @services = YAML.load_file(
        "#{File.expand_path('../', __FILE__)}/config/#{version}.yml"
      )[environment.to_s.upcase]

      services.each do |serv, url|
        define_singleton_method(serv) { Service.new(url, credentials) }
      end
    end
  end
end
