# frozen_string_literal: true
require 'bing_ads_ruby_sdk/wsdl_operation_wrapper'
require "bing_ads_ruby_sdk/http_client"

module BingAdsRubySdk
  class SoapClient

    def initialize(service_name:, version:, environment:, header:)
      @header = header
      @wsdl_file_path = File.join(BingAdsRubySdk.root_path, 'lib', 'bing_ads_ruby_sdk', 'wsdl', version.to_s, environment.to_s, "#{service_name}.xml")
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

      BingAdsRubySdk.logger.debug { format_xml(req.content) }

      raw_response = BingAdsRubySdk::HttpClient.post(req)

      parse_response(req, raw_response)
    end

    def wsdl_wrapper(operation_name)
      BingAdsRubySdk::WsdlOperationWrapper.new(lolsoap_parser, operation_name)
    end

    private

    attr_reader :client, :header

    XSI_NAMESPACE = "http://www.w3.org/2001/XMLSchema-instance"

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
          if arg_name == BingAdsRubySdk.type_key
            node.__attribute__(
              "#{BingAdsRubySdk.xsi_namespace_key}:#{arg_name[1..-1]}",
              lolsoap_wsdl.types[arg_value].prefix_and_name
            )
          else
            node.__send__(arg_name, arg_value)
          end
        end
      end
    end

    def parse_response(req, raw_response)
      if contains_error?(raw_response)
        BingAdsRubySdk.logger.warn { format_xml(raw_response.body) }
        raise BingAdsRubySdk::Errors::ServerError, raw_response
      else
        BingAdsRubySdk.logger.debug { format_xml(raw_response.body) }
      end

      lolsoap_client.response(req, raw_response.body).body_hash.tap do |b_h|
        BingAdsRubySdk.logger.debug { b_h }
        BingAdsRubySdk::Errors::ErrorHandler.new(b_h).call
      end
    end

    def contains_error?(response)
      [
        Net::HTTPServerError,
        Net::HTTPClientError,
      ].any? { |http_error_class| response.class <= http_error_class }
    end

    def lolsoap_client
      @lolsoap ||= LolSoap::Client.new(lolsoap_wsdl).tap do |c|
        c.wsdl.namespaces[BingAdsRubySdk.xsi_namespace_key] = XSI_NAMESPACE
      end
    end

    def lolsoap_wsdl
      @lolsoap_wsdl ||= LolSoap::WSDL.new(lolsoap_parser)
    end

    def lolsoap_parser
      @lolsoap_parser ||= LolSoap::WSDLParser.parse(File.read(@wsdl_file_path))
    end

    def format_xml(string)
      Nokogiri::XML(string).to_xhtml(indent: 2)
    end
  end
end