# frozen_string_literal: true

require 'bing_ads_ruby_sdk/wsdl_operation_wrapper'
require 'bing_ads_ruby_sdk/augmented_parser'
require 'bing_ads_ruby_sdk/http_client'
require 'bing_ads_ruby_sdk/log_message'

module BingAdsRubySdk
  class SoapClient
    def initialize(service_name:, version:, environment:, header:)
      @header = header
      @lolsoap_parser, @concrete_abstract_mapping = cache(service_name) do
        ::BingAdsRubySdk::AugmentedParser.new(
          path_to_wsdl(version, environment, service_name)
        ).call
      end
    end

    def call(operation_name, message = {})
      request = lolsoap_client.request(operation_name)

      request.header do |h|
        header.content.each do |k, v|
          h.__send__(k, v)
        end
      end
      request.body do |node|
        insert_args(message, node)
      end

      BingAdsRubySdk.log(:debug) { format_xml(request.content) }

      response_body = BingAdsRubySdk::HttpClient.post(request)

      parse_response(request, response_body)
    end

    def wsdl_wrapper(operation_name)
      WsdlOperationWrapper.new(lolsoap_parser, operation_name)
    end

    private

    attr_reader :client, :header, :concrete_abstract_mapping, :lolsoap_parser

    def insert_args(args, node)
      # if ever the current node is a subtype
      if (base_type_name = concrete_abstract_mapping[node.__type__.name])
        # and add an attribute to specify the real type we want
        node.__attribute__(
          type_attribute_name,
          "#{node.__type__.prefix}:#{node.__node__.name}"
        )
        # we have to change the node name to the base type
        node.__node__.name = base_type_name
      end

      args.each do |arg_name, arg_value|
        case arg_value
        when Hash
          node.__send__(arg_name) do |subnode|
            insert_args(arg_value, subnode)
          end
        when Array
          node.__send__(arg_name) do |subnode|
            # arrays can only contain hashes
            arg_value.each do |elt|
              insert_args(elt, subnode)
            end
          end
        else
          if arg_name == BingAdsRubySdk.type_key
            # this is for now only useful for Account. Indeed, for some unknown reason
            # Account is abstract, AdvertiserAccount is the only expect subtype
            # yet the wsdl doesnt declare it as an actual subtype
            node.__attribute__(
              type_attribute_name,
              prefixed_type_name(arg_value)
            )
          else
            node.__send__(arg_name, arg_value)
          end
        end
      end
    end

    def parse_response(req, response_body)
      lolsoap_client.response(req, response_body).body_hash
    end

    def lolsoap_client
      @lolsoap ||= LolSoap::Client.new(lolsoap_wsdl).tap do |c|
        c.wsdl.namespaces[XSI_NAMESPACE_KEY] = XSI_NAMESPACE
      end
    end

    def lolsoap_wsdl
      @lolsoap_wsdl ||= LolSoap::WSDL.new(lolsoap_parser)
    end

    def format_xml(string)
      BingAdsRubySdk::LogMessage.new(string).to_s
    end

    def path_to_wsdl(version, environment, service_name)
      File.join(
        BingAdsRubySdk.root_path,
        'lib',
        'bing_ads_ruby_sdk',
        'wsdl',
        version.to_s,
        environment.to_s,
        "#{service_name}.xml"
      )
    end

    def prefixed_type_name(typename)
      WsdlOperationWrapper.prefix_and_name(lolsoap_wsdl, typename)
    end

    def type_attribute_name
      "#{XSI_NAMESPACE_KEY}:type"
    end

    def cache(name)
      self.class.cached_parsers[name] ||= yield
    end

    @cached_parsers = {}
    class << self
      attr_reader :cached_parsers
    end

    XSI_NAMESPACE_KEY = 'xsi'
    XSI_NAMESPACE = 'http://www.w3.org/2001/XMLSchema-instance'
  end
end
