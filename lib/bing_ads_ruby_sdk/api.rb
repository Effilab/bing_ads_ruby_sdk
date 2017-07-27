# require 'lolsoap'
require 'YAML'
require 'bing_ads_ruby_sdk/service'
# require 'open-uri'

module BingAdsRubySdk
  class Api
    attr_reader :services

    def initialize(version: :v11, environment: :production, credentials: {})
      @services = YAML.load_file(
        "#{File.expand_path('../', __FILE__)}/config/#{version}.yml"
      )[environment.to_s.upcase]

      services.each do |serv, url|
        define_singleton_method(serv) { Service.new(url, credentials) }
      end
    end
  end
end
