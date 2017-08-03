require 'yaml'
require 'logger'
require 'fileutils'
require 'bing_ads_ruby_sdk/service'
require 'bing_ads_ruby_sdk/header'

module BingAdsRubySdk
  class Api

    attr_reader :services, :header, :cache_path

    # @param config [Hash] shared soap header customer parameters
    # @option config [Symbol] :id customer id
    # @option config [Symbol] :account_id customer account_id
    def customer(config)
      header.customer = config
    end

    def load_or_parse(service, url, header)
      file = "#{cache_path}/#{service}"
      if File.file?(file)
        BingAdsRubySdk.logger.info('From cache')
        Marshal.load(IO.read(file))
      else
        serv = Service.new(url, header)
        # Marshal don't work with singleton methods
        # Do as atomic_write does to avoid broken cache
        Marshal.dump(serv, File.open(file, 'w+'))
        serv
      end
    end

    def initialize(version: :v11,
                   environment: :production,
                   credentials: {})

      @header = Header.new(credentials)
      @services = YAML.load_file(
        "#{File.expand_path('../', __FILE__)}/config/#{version}.yml"
      )[environment.to_s.upcase]
      @cache_path = "#{File.expand_path('../', __FILE__)}/.cache/#{version}"
      FileUtils.mkdir_p @cache_path

      services.each do |serv, url|
        BingAdsRubySdk.logger.info("Defining service #{serv} accessors")
        # TODO : hmm or define_singleton_method ?
        self.class.send(:attr_reader, serv)
        instance_variable_set("@#{serv}", Service.new(url, header))
      end
    end
  end
end
