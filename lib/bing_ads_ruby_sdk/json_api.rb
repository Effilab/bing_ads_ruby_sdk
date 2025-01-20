# frozen_string_literal: true

require "bing_ads_ruby_sdk/header"
require "bing_ads_ruby_sdk/soap_client"
require "bing_ads_ruby_sdk/services/base"
require "bing_ads_ruby_sdk/services/ad_insight"
require "bing_ads_ruby_sdk/services/bulk"
require "bing_ads_ruby_sdk/services/campaign_management"
require "bing_ads_ruby_sdk/services/customer_billing"
require "bing_ads_ruby_sdk/services/customer_management"
require "bing_ads_ruby_sdk/services/reporting"
require "bing_ads_ruby_sdk/oauth2/authorization_handler"
require "bing_ads_ruby_sdk/errors/errors"
require "bing_ads_ruby_sdk/errors/error_handler"

module BingAdsRubySdk
  class JsonApi
    attr_reader :header

    # @param version [Symbol] API version, used to choose version
    # @param environment [Symbol]
    # @option environment [Symbol] :production Use the production environment
    # @option environment [Symbol] :sandbox Use the sandbox environment
    # @param developer_token
    # @param client_id
    def initialize(developer_token:, client_id:, oauth_store:, version: DEFAULT_SDK_VERSION,
      environment: :production,
      client_secret: nil)
      @version = version
      @environment = environment
      @header = Header.new(
        developer_token: developer_token,
        client_id: client_id,
        client_secret: client_secret,
        store: oauth_store
      )

    end

    def campaign_management
      build_service(:campaign_management)
    end

    def set_customer(account_id:, customer_id:)
      header.set_customer(account_id: account_id, customer_id: customer_id)
    end

    private

    attr_reader :lolsoap_parser

    def build_service(service_name)
      @lolsoap_parser = LolSoap::WSDLParser.parse()
    end

    def lolsoap_client(service_name)
      @lolsoap ||= LolSoap::Client.new(lolsoap_wsdl(service_name)).tap do |c|
        c.wsdl.namespaces[XSI_NAMESPACE_KEY] = XSI_NAMESPACE
      end
    end

    def lolsoap_wsdl()
      @lolsoap_wsdl ||= LolSoap::WSDL.new(lolsoap_parser)
    end

    def request_url(operation_name)
      lolsoap_client.request(operation_name)
    end

    def path_to_wsdl(version, environment, service_name)
      File.join(
        BingAdsRubySdk.root_path,
        "lib",
        "bing_ads_ruby_sdk",
        "wsdl",
        version.to_s,
        environment.to_s,
        "#{service_name}.xml"
      )
    end
  end
end
