# frozen_string_literal: true

module BingAdsRubySdk
  class Configuration
    attr_accessor :pretty_print_xml, :filters, :log, :instrumentor,
                  :developer_token, :client_id, :client_secret, :filename,
                  :customer_id, :account_id
    attr_writer :logger

    def initialize
      @log = false
      @pretty_print_xml = false
      @filters = []
      @instrumentor = nil

      @developer_token = nil
      @client_id = nil
      @client_secret = nil
      @filename = nil
      @customer_id = nil
      @account_id = nil
    end

    def logger
      @logger ||= default_logger
    end

    private

    def default_logger
      Logger.new(File.join(BingAdsRubySdk::ROOT_PATH, 'log', 'bing-sdk.log')).tap do |l|
        l.level = Logger::INFO
      end
    end
  end
end
