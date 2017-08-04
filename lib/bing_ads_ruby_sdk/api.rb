require 'yaml'
require 'logger'
require 'fileutils'
require 'bing_ads_ruby_sdk/service'
require 'bing_ads_ruby_sdk/header'

module BingAdsRubySdk
  class Api

    attr_reader :header
    # , :cache_path

    # @param config [Hash] shared soap header customer parameters
    # @option config [Symbol] :id customer id
    # @option config [Symbol] :account_id customer account_id
    def customer(config)
      header.customer = config
    end

    # def load_or_parse(service, url, header)
    #   file = "#{cache_path}/#{service}"
    #   if File.file?(file)
    #     BingAdsRubySdk.logger.info('From cache')
    #     Marshal.load(IO.read(file))
    #   else
    #     serv = Service.new(url, header)
    #     # Marshal don't work with singleton methods
    #     # Do as atomic_write does to avoid broken cache
    #     Marshal.dump(serv, File.open(file, 'w+'))
    #     serv
    #   end
    # end

    # @param version [Symbol] API version, used to choose WSDL configuration version
    # @param environment [Symbol]
    # @option environment [Symbol] :production Use the production WSDL configuration
    # @option environment [Symbol] :sandbox Use the sandbox WSDL configuration
    # @param credentials [Hash]
    # @option credentials [String] :developer_token The developer token used to access the API
    # @option credentials [String] :client_id The client ID used to acces the API
    def initialize(version: :v11,
                   environment: :production,
                   credentials: {})

      @header = Header.new(credentials)
      # Get the URLs for the WSDL that defines the services on the API
      api_config = YAML.load_file(
        "#{File.expand_path('../', __FILE__)}/config/#{version}.yml"
      )
      # @cache_path = "#{File.expand_path('../', __FILE__)}/.cache/#{version}"
      # FileUtils.mkdir_p @cache_path

      # Create a service object based on the WSDL in each configuration entry
      api_config[environment.to_s.upcase].each do |serv, url|
        BingAdsRubySdk.logger.info("Defining service #{serv} accessors")
        self.class.send(:attr_reader, serv)
        instance_variable_set(
          "@#{serv}",
          Service.new(url, header, api_config['ABSTRACT'][serv])
        )
      end
    end
  end
end
