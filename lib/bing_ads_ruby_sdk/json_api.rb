# frozen_string_literal: true

require "bing_ads_ruby_sdk/header"
require "bing_ads_ruby_sdk/oauth2/authorization_handler"
require "bing_ads_ruby_sdk/services/json/campaign_management"

module BingAdsRubySdk
  class JsonApi
    attr_reader :headers
    URL_MAP = {
      campaign_management: "https://campaign.api.%{sandbox}bingads.microsoft.com/CampaignManagement/%{version}/"
    }.freeze

    SERVICE_CLASSES = {
      campaign_management: Services::Json::CampaignManagement
    }.freeze

    # @param developer_token
    # @param client_id
    # @param client_secret
    # @param oauth_store instance of a store, used to get OAuth credentials
    # @param version [Symbol] API version, used to choose version
    # @param environment [Symbol]
    # @option environment [Symbol] :production Use the production environment
    # @option environment [Symbol] :sandbox Use the sandbox environment
    def initialize(
      developer_token:,
      client_id:,
      client_secret:,
      oauth_store:,
      version: DEFAULT_SDK_VERSION,
      environment: :production
    )
      # Validate version format
      raise ArgumentError, "Invalid version format" unless version.to_s.match?(/\Av\d+\z/)
      @version = version
      @sandbox = (environment == :production) ? "" : "sandbox."
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
        client_secret: client_secret,
        store: oauth_store
      )
    end

    def campaign_management
      @campaign_management ||= build_service(:campaign_management)
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
      SERVICE_CLASSES.fetch(service_name).new(
        base_url: base_url(service_name),
        headers: headers,
        auth_handler: auth_handler
      )
    end

    def base_url(service_name)
      URL_MAP.fetch(service_name) % {version: @version, sandbox: @sandbox}
    end
  end
end
