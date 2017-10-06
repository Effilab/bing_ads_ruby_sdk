require 'fileutils'
require 'lolsoap'
require 'open-uri'
require 'bing_ads_ruby_sdk/logger'
require 'bing_ads_ruby_sdk/configuration'
require 'bing_ads_ruby_sdk/wsdl_parser'

module BingAdsRubySdk
  # Manages wsdl cache, DO NOT require in projet to avoid circular require
  class Cache
    class << self
      def clear
        BingAdsRubySdk::Configuration.all do |config|
          config.services.keys.each do |serv|
            BingAdsRubySdk.logger.warn("Deleting cache file : #{File.join(config.cache_path, serv)}")
            begin
              File.unlink(File.join(config.cache_path, serv))
            rescue Errno::ENOENT
              BingAdsRubySdk.logger.warn("Cache file not found : #{File.join(config.cache_path, serv)}")
            end
          end
        end
      end

      def build
        BingAdsRubySdk::Configuration.all do |config|
          FileUtils.mkdir_p(config.cache_path)
          config.services.each do |serv, url|
            file_path = File.join(config.cache_path, serv)
            BingAdsRubySdk.logger.info("Caching service to file : #{file_path}")
            parser = WSDLParser.new(
              config.abstract[serv],
              File.read(open(url))
            ).parser
            LolSoap::Client.new(LolSoap::WSDL.new(parser)).tap do |client|
              File.open(file_path, 'w+') { |f| Marshal.dump(client, f) }
            end
          end
        end
      end

      def check
        BingAdsRubySdk::Configuration.all do |config|
          config.services.keys.each do |serv|
            BingAdsRubySdk.logger.info("Checking cached file : #{File.join(config.cache_path, serv)}")
            config.cached(serv)
          end
        end
      end
    end
  end
end
