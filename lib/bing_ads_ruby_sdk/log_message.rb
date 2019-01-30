# frozen_string_literal: true

module BingAdsRubySdk
  class LogMessage

    def initialize(message)
      @message = message
    end

    def to_s
      return message unless message_is_xml
      return message unless filters.any? || pretty_print

      document = Nokogiri::XML(message)
      document = apply_filter(document) if filters.any?
      document.to_xml(nokogiri_options)
    end

    FILTERED = "***FILTERED***"

    private

    attr_reader :message

    def message_is_xml
      message =~ /^</
    end

    def apply_filter(document)
      return document unless document.errors.empty?

      filters.each do |filter|
        apply_filter! document, filter
      end

      document
    end

    def apply_filter!(document, filter)
      document.xpath("//*[local-name()='#{filter}']").each do |node|
        node.content = FILTERED
      end
    end

    def nokogiri_options
      pretty_print ? { indent: 2 } : { save_with: Nokogiri::XML::Node::SaveOptions::AS_XML }
    end

    def pretty_print
      BingAdsRubySdk.config.pretty_print_xml
    end

    def filters
      BingAdsRubySdk.config.filters
    end
  end
end