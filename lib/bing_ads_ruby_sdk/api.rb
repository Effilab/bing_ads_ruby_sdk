require 'yaml'
require 'logger'
require 'fileutils'
require 'lolsoap'
require 'bing_ads_ruby_sdk/soap_callback_manager'
require 'bing_ads_ruby_sdk/service'
require 'bing_ads_ruby_sdk/header'
require 'bing_ads_ruby_sdk/oauth2/authorization_code'
require 'bing_ads_ruby_sdk/errors/application_fault'
require 'bing_ads_ruby_sdk/errors/error_handler'
require 'awesome_print'

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
      @api_config = env_for(version)
      SoapCallbackManager.register_callbacks
      @token  = token(credentials, oauth_store)
      @header = Header.new(credentials, @token)
      # Get the URLs for the WSDL that defines the services on the API
      # Create services accessors and objects from each named wsdl
      build_services(environment)
    end

    private

    def build_services(environment)
      @api_config[environment.to_s.upcase].each do |serv, url|
        BingAdsRubySdk.logger.debug("Defining service #{serv} accessors")
        self.class.send(:attr_reader, serv)
        client = load_or_new(serv, url)
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
        # The parser is a convenient way to parse the wsdl using nokogiri.
        parser = LolSoap::WSDLParser.parse(File.read(open(url)))
        add_abstract_for_operations(parser, serv)
        add_abstract_for_types(parser, serv)
        LolSoap::Client.new(LolSoap::WSDL.new(parser)).tap do |client|
          # TODO : as atomic_write does to avoid broken cache
          File.open(file, 'w+') { |f| Marshal.dump(client, f) }
        end
      end
    end

    def abstract_types
      @api_config['ABSTRACT']
    end

    def add_abstract_for_operations(parser, serv)
      return nil if abstract_types[serv].nil?

      parser.operations.each do |_name, content|
        content[:input][:body].each do |full_name|
          parser.elements[full_name][:type][:elements].keys.each do |base|
            next if abstract_types[serv][base].nil?

            # here the namespace is part of the type full_name
            namespace = parser.elements[full_name][:type][:elements][base][:type].first
            abstract_types[serv][base].each do |concrete|
              elem = parser.elements[[namespace, concrete]]
              byebug if elem.nil?
              # Inject concrete element in types containing the abstract element
              # We use the concrete element name as a keyto build the soap body
              # We'll use the abstract element name as the xml node name
              # We'll have to add the attribute "type" later
              parser.elements[full_name][:type][:elements][elem[:name]] = elem.merge(name: base)
            end
          end
        end
      end
    end

    def add_abstract_for_types(parser, serv)
      return nil if abstract_types[serv].nil?

      parser.types.each do |_full_name, content|
        content[:elements].keys.each do |base|
          next if abstract_types[serv][base].nil?

          namespace = content[:elements][base][:namespace]
          abstract_types[serv][base].each do |concrete|
            elem = parser.elements[[namespace, concrete]]
            # Inject concrete element in types containing the abstract element
            # We use the concrete element name as a keyto build the soap body
            # We'll use the abstract element name as the xml node name
            # We'll have to add the attribute "type" later
            content[:elements][elem[:name]] = elem.merge(name: base)
          end
        end
      end
    end
  end
end
