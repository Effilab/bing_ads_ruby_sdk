# frozen_string_literal: true

require "bing_ads_ruby_sdk/header"
require "bing_ads_ruby_sdk/oauth2/authorization_handler"
require "bing_ads_ruby_sdk/services/json"

module BingAdsRubySdk
  class JsonApi
    attr_reader :headers

    URL_MAP = {
      campaign_management: "https://campaign.api.bingads.microsoft.com/CampaignManagement/v13/"
    }

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
      @headers = {
        "DeveloperToken" => developer_token,
        "ClientId" => client_id,
        "ClientSecret" => client_secret,
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
      @auth_handler = ::BingAdsRubySdk::OAuth2::AuthorizationHandler.new(
        developer_token: developer_token,
        client_id: client_id,
        store: oauth_store,
        client_secret: client_secret
      )
    end

    def campaign_management
      build_service(:campaign_management)
    end

    def set_customer(account_id:, customer_id:)
      headers.merge!(
        "CustomerAccountId" => account_id,
        "CustomerId" => customer_id
      )
    end

    private

    attr_reader :auth_handler

    def build_service(service_name)
      Services::Json.new(
        base_url: URL_MAP.fetch(service_name),
        headers: headers,
        auth_handler: auth_handler
      )
    end
  end
end
