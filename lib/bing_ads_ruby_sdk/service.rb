require 'lolsoap'
require 'bing_ads_ruby_sdk/utils'
require 'net/http'
require 'open-uri'

module BingAdsRubySdk

  # Manages communication with the a defined SOAP service on the API
  class Service
    attr_reader :client, :shared_header

    def with_abstract(abstract_types, wsdl)
      return yield if abstract_types.nil?

      BingAdsRubySdk.abstract_callback.for('hash_params.before_build') << lambda do |args, node, type|
        args.each do |h|
          abstract_types.each do |concrete, abstract|
            next unless concrete.tr('_', '').casecmp(h[:name].tr('_', '')).zero?

            BingAdsRubySdk.logger.info("Building concrete type : #{concrete}")
            node.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
            h[:args] << { 'xsi:type' => wsdl.types[concrete].prefix_and_name }
            h[:name] = abstract
            h[:sub_type] = wsdl.types[concrete]
          end
        end
      end
      yield
      BingAdsRubySdk.abstract_callback.for('hash_params.before_build').clear
    end

    def initialize(url, shared_header, abstract_map)
      @client = LolSoap::Client.new(File.read(open(url)))
      @shared_header = shared_header
      abstract_map ||= {}
      BingAdsRubySdk.logger.info("Parsing WSDL : #{url}")

      operations.keys.each do |op|
        BingAdsRubySdk.logger.info("Defining operation : #{op}")
        define_singleton_method(Utils.snakize(op)) do |body = false|
          request(op, body, abstract_map[op])
        end
      end
    end

    def operations
      client.wsdl.operations
    end

    def request(name, body, abstract_types)
      req = client.request(name)
      req.header.content(shared_header.content)

      with_abstract(abstract_types, client.wsdl) do
        req.body.content(body) if body
      end

      BingAdsRubySdk.logger.info("Operation : #{name}")
      BingAdsRubySdk.logger.debug(req.content)
      url = URI(req.url)
      raw_response =
        Net::HTTP.start(url.hostname,
                        url.port,
                        use_ssl: url.scheme == 'https') do |http|
          http.post(url.path, req.content, req.headers)
        end
      client.response(req, raw_response.body).body_hash.tap do |b_h|
        BingAdsRubySdk.logger.debug(b_h)
      end
    end
  end
end
