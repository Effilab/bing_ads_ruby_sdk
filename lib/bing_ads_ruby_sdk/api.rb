# frozen_string_literal: true

require "bing_ads_ruby_sdk/header"
require "bing_ads_ruby_sdk/soap_client"
require "bing_ads_ruby_sdk/services/base"
require "bing_ads_ruby_sdk/services/ad_insight"
require "bing_ads_ruby_sdk/services/bulk"
require "bing_ads_ruby_sdk/services/campaign_management"
require "bing_ads_ruby_sdk/services/customer_billing"
require "bing_ads_ruby_sdk/services/customer_management"
require "bing_ads_ruby_sdk/services/json"
require "bing_ads_ruby_sdk/services/reporting"
require "bing_ads_ruby_sdk/oauth2/authorization_handler"
require "bing_ads_ruby_sdk/errors/errors"
require "bing_ads_ruby_sdk/errors/error_handler"

module BingAdsRubySdk
  class Api
    attr_reader :header

    # @param version [Symbol] API version, used to choose WSDL configuration version
    # @param environment [Symbol]
    # @option environment [Symbol] :production Use the production WSDL configuration
    # @option environment [Symbol] :sandbox Use the sandbox WSDL configuration
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

    def ad_insight
      build_service(BingAdsRubySdk::Services::AdInsight)
    end

    def bulk
      build_service(BingAdsRubySdk::Services::Bulk)
    end

    def campaign_management
      build_service(BingAdsRubySdk::Services::CampaignManagement)
    end

    def customer_billing
      build_service(BingAdsRubySdk::Services::CustomerBilling)
    end

    def customer_management
      build_service(BingAdsRubySdk::Services::CustomerManagement)
    end

    def reporting
      build_service(BingAdsRubySdk::Services::Reporting)
    end

    def set_customer(account_id:, customer_id:)
      header.set_customer(account_id: account_id, customer_id: customer_id)
    end

    private

    def build_service(klass)
      klass.new(
        BingAdsRubySdk::SoapClient.new(
          version: @version,
          environment: @environment,
          header: header,
          service_name: klass.service
        )
      )
    end
  end
end
