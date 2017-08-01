require 'lolsoap'
require 'bing_ads_ruby_sdk/lolsoap_callbacks/initialize'
require 'net/http'
require 'open-uri'

module BingAdsRubySdk
  class Service
    attr_reader :client, :shared_header

    def initialize(url, shared_header)
      @client = LolSoap::Client.new(File.read(open(url)))
      @shared_header = shared_header

      BingAdsRubySdk.logger.info("Parsing WSDL : #{url}")

      operations.keys.each do |op|
        BingAdsRubySdk.logger.info("Defining opération : #{op}")
        define_singleton_method(snakize(op)) { |body = false| request(op, body) }
      end
    end

    def snakize(string)
      string.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
    end

    def operations
      client.wsdl.operations
    end

    def request(name, body)
      req = client.request(name)
      req.header.content(shared_header.content)
      req.body.content(body) if body
      BingAdsRubySdk.logger.info("Opération : #{name}")
      BingAdsRubySdk.logger.debug(req.content)
      url = URI(req.url)
      raw_response =
        Net::HTTP.start(url.hostname,
                        url.port,
                        use_ssl: url.scheme == 'https') do |http|
          http.post(url.path, req.content, req.headers)
        end
      client.response(req, raw_response.body).body_hash
    end
  end
end
