require 'yaml'

module BingAdsRubySdk
  # Gem configuration
  class Configuration
    ENVIRONMENTS = %i[production sandbox].freeze
    VERSIONS     = %i[v11].freeze
    CACHE_BASE   = __dir__
    CONF_PATH    = File.join(__dir__, 'config')

    attr_reader :data, :version, :environment, :cache_path, :abstract

    def initialize(version: :v11, environment: :production)
      @version     = version
      @environment = environment
      @cache_path  = File.join(CACHE_BASE, '.cache', version.to_s, environment.to_s)
      @data = YAML.load_file(File.join(CONF_PATH, "#{version}.yml"))
      @abstract = @data['ABSTRACT']
    end

    def services
      data[environment.to_s.upcase]
    end

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

    def self.all
      VERSIONS.each do |version|
        ENVIRONMENTS.each do |environment|
          yield new(version: version, environment: environment)
        end
      end
    end
  end
end
