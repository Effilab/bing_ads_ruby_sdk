require 'yaml'

module BingAdsRubySdk
  # Gem internal configuration
  class Configuration
    # Sets Bing Ads available environments, this will increase cache size.
    ENVIRONMENTS = %i[production sandbox test].freeze
    # Sets Gem supported versions, this will increase cache size.
    VERSIONS     = %i[v12].freeze
    # Sets cache location, will contain ".cache/version[s]/environment[s]/service".
    CACHE_BASE   = __dir__
    # Sets version.yml location, see v12.yml for future versions.
    CONF_PATH    = File.join(__dir__, 'config')

    attr_reader :data, :version, :environment, :cache_path, :abstract

    # @param version [Symbol] API version, used to choose WSDL configuration version.
    # @param environment [Symbol]
    # @option environment [Symbol] :production Use the production WSDL configuration.
    # @option environment [Symbol] :sandbox Use the sandbox WSDL configuration.
    def initialize(version: DEFAULT_SDK_VERSION, environment: :production)
      @version     = version
      @environment = environment
      @cache_path  = File.join(CACHE_BASE, '.cache', version.to_s, environment.to_s)
      @data = YAML.load_file(File.join(CONF_PATH, "#{version}.yml"))
      @abstract = @data['ABSTRACT']
    end

    # @return [Hash] { "service name" => "service url" }
    def services
      data[environment.to_s.upcase]
    end

    # @return [LolSoap::Client]
    # @raise [Errno::ENOENT] Cache file not found.
    # @raise [ArgumentError] Unmarshalling failure.
    def cached(serv)
      BingAdsRubySdk.logger.debug("Client #{serv} from cache")
      Marshal.load(
        File.read(
          File.join(cache_path, serv)
        )
      )
    rescue Errno::ENOENT => e
      BingAdsRubySdk.logger.fatal(
        "Cache error for #{cache_path}/#{serv}, check if the service exists."
      )
      raise e
    rescue ArgumentError => e
      BingAdsRubySdk.logger.fatal(
        "Cache error for #{cache_path}/#{serv}, data corrupted."
      )
      raise e
    end

    # @yield [BingAdsRubySdk::Configuration] all versions environments combinations are instanciated.
    def self.all
      VERSIONS.each do |version|
        ENVIRONMENTS.each do |environment|
          yield new(version: version, environment: environment)
        end
      end
    end
  end
end
