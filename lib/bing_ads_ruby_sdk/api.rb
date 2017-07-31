require 'YAML'
require 'bing_ads_ruby_sdk/service'
require 'bing_ads_ruby_sdk/header'

module BingAdsRubySdk
  class Api
    attr_reader :services, :header

    # @param config [Hash] shared soap header customer parameters
    # @option config [Symbol] :id customer id
    # @option config [Symbol] :account_id customer account_id
    def customer(config)
      header.customer = config
    end

    def initialize(version: :v11,
                   environment: :production,
                   credentials: {})

      @header = Header.new(credentials)

      @services = YAML.load_file(
        "#{File.expand_path('../', __FILE__)}/config/#{version}.yml"
      )[environment.to_s.upcase]

      services.each do |serv, url|
        puts "Defining service #{serv} accessors"
        # TODO : hmm or define_singleton_method ?
        self.class.send(:attr_reader, serv)
        instance_variable_set("@#{serv}", Service.new(url, header))
      end
    end
  end
end
