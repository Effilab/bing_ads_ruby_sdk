# frozen_string_literal: true
require 'bing_ads_ruby_sdk/wsdl_operation_wrapper'
require "bing_ads_ruby_sdk/http_client"
require "bing_ads_ruby_sdk/log_message"

module BingAdsRubySdk
  class SoapClient

    def initialize(service_name:, version:, environment:, header:)
      @header = header
      @wsdl_file_path = path_to_wsdl(version, environment, service_name)
    end

    def call(operation_name, message = {})
      req = lolsoap_client.request(operation_name)

      req.header do |h|
        header.content.each do |k, v|
          h.__send__(k, v)
        end
      end
      req.body do |node|
        insert_args(message, node)
      end

      BingAdsRubySdk.log(:debug) { format_xml(req.content) }

      response_body = BingAdsRubySdk::HttpClient.post(req)

      parse_response(req, response_body)
    end

    def wsdl_wrapper(operation_name)
      WsdlOperationWrapper.new(lolsoap_parser, operation_name)
    end

    def self.type_key
      TYPE_KEY
    end

    private

    attr_reader :client, :header

    def insert_args(args, node)
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
          if arg_name == TYPE_KEY
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
      lolsoap_client.response(req, response_body).body_hash.tap do |b_h|
        BingAdsRubySdk.log(:debug) { b_h }
        BingAdsRubySdk::Errors::ErrorHandler.new(b_h).call
      end
    rescue BingAdsRubySdk::Errors::GeneralError => e
      BingAdsRubySdk.log(:warn) { format_xml(response_body) }
      raise e
    end

    def lolsoap_client
      @lolsoap ||= LolSoap::Client.new(lolsoap_wsdl).tap do |c|
        c.wsdl.namespaces[XSI_NAMESPACE_KEY] = XSI_NAMESPACE
      end
    end

    def lolsoap_wsdl
      @lolsoap_wsdl ||= LolSoap::WSDL.new(lolsoap_parser)
    end

    def lolsoap_parser
      @lolsoap_parser ||= LolSoap::WSDLParser.parse(File.read(@wsdl_file_path))
    end

    def format_xml(string)
      BingAdsRubySdk::LogMessage.new(string).to_s
    end

    def type_attribute_name
      "#{XSI_NAMESPACE_KEY}:type"
    end

    def prefixed_type_name(typename)
      WsdlOperationWrapper.prefix_and_name(lolsoap_wsdl, typename)
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

    TYPE_KEY = "@type"
    XSI_NAMESPACE_KEY = "xsi"
    XSI_NAMESPACE = "http://www.w3.org/2001/XMLSchema-instance"
  end
end