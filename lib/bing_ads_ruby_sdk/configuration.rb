# frozen_string_literal: true

module BingAdsRubySdk
  class Configuration
    attr_accessor :pretty_print_xml, :filters, :log, :instrumentor
    attr_writer :logger

    def initialize
      @log = false
      @pretty_print_xml = false
      @filters = []
      @instrumentor = nil
    end

    def logger
      @logger ||= default_logger
    end

    private

    def default_logger
      Logger.new(File.join(BingAdsRubySdk::ROOT_PATH, "log", "bing-sdk.log")).tap do |l|
        l.level = Logger::INFO
      end
    end
  end
end