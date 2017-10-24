require 'lolsoap'
require 'bing_ads_ruby_sdk/soap_callback_manager'
require 'bing_ads_ruby_sdk/service'
require 'bing_ads_ruby_sdk/header'
require 'bing_ads_ruby_sdk/configuration'
require 'bing_ads_ruby_sdk/oauth2/authorization_code'
require 'bing_ads_ruby_sdk/errors/application_fault'
require 'bing_ads_ruby_sdk/errors/error_handler'

module BingAdsRubySdk
  SoapCallbackManager.register_callbacks

  class Api
    attr_reader :header, :config

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
      @config = Configuration.new(version: version, environment: environment)
      @token  = token(credentials, oauth_store)
      @header = Header.new(credentials, @token)
      # Get the URLs for the WSDL that defines the services on the API
      # Create services accessors and objects from each named wsdl
      build_services
    end

    private

    def build_services
      config.services.keys.each do |serv|
        BingAdsRubySdk.logger.debug("Defining service #{serv} accessors")
        self.class.send(:attr_reader, serv)
        client = config.cached(serv)
        instance_variable_set(
          "@#{serv}",
          Service.new(client, header)
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
  end
end
