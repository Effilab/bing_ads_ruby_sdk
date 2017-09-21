require 'yaml'
require 'logger'
require 'fileutils'
require 'lolsoap'
require 'bing_ads_ruby_sdk/service'
require 'bing_ads_ruby_sdk/header'
require 'bing_ads_ruby_sdk/oauth2/authorization_code'
require 'bing_ads_ruby_sdk/errors/application_fault'
require 'bing_ads_ruby_sdk/errors/error_handler'

module BingAdsRubySdk
  class Api

    attr_reader :header

    # @param config [Hash] shared soap header customer parameters
    # @option config [Symbol] :id customer id
    # @option config [Symbol] :account_id customer account_id
    def customer(config)
      header.customer = config
    end

    # @param version [Symbol] API version, used to choose WSDL configuration version
    # @param environment [Symbol]
    # @option environment [Symbol] :production Use the production WSDL configuration
    # @option environment [Symbol] :sandbox Use the sandbox WSDL configuration
    # @param credentials [Hash]
    # @option credentials [String] :developer_token The developer token used to access the API
    # @option credentials [String] :client_id The client ID used to acces the API
    def initialize(version: :v11,
                   environment: :production,
                   oauth_store: OAuth2::FsStore,
                   credentials: {})
      @token  = token(credentials, oauth_store)
      @header = Header.new(credentials, @token)
      # Get the URLs for the WSDL that defines the services on the API
      @api_config = env_for(version)
      # Create services accessors and objects from each named wsdl
      build_services(environment)
    end

    private

    def build_services(environment)
      @api_config[environment.to_s.upcase].each do |serv, url|
        BingAdsRubySdk.logger.debug("Defining service #{serv} accessors")
        self.class.send(:attr_reader, serv)

        client = load_or_new(serv, url)
        client.wsdl.namespaces['xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'

        instance_variable_set(
          "@#{serv}",
          Service.new(client, header, @api_config['ABSTRACT'][serv])
        )
      end
    end

    def token(credentials, store)
      OAuth2::AuthorizationCode.new(
        {
          developer_token: credentials[:developer_token],
          client_id:       credentials[:client_id]
        },
        store: store
      )
    end

    def env_for(version)
      @cache_path = File.join(__dir__, '.cache', version.to_s)
      FileUtils.mkdir_p @cache_path
      YAML.load_file(
        File.join(__dir__, 'config', "#{version}.yml")
      )
    end

    def load_or_new(serv, url)
      file = File.join(@cache_path, serv)
      if File.file?(file)
        BingAdsRubySdk.logger.debug("Client #{serv} from cache")
        Marshal.load(IO.read(file))
      else
        BingAdsRubySdk.logger.info("Client #{serv} from URL")
        LolSoap::Client.new(File.read(open(url))).tap do |client|
          # TODO : as atomic_write does to avoid broken cache
          File.open(file, 'w+') { |f| Marshal.dump(client, f) }
        end
      end
    end

  end
end
