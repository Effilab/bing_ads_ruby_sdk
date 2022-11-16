# frozen_string_literal: true

module BingAdsRubySdk
  class WsdlOperationWrapper
    attr_reader :request_namespace_type

    def initialize(parser, operation_name)
      @parser = parser
      @request_namespace_type = parser.operations.fetch(operation_name).fetch(:input).fetch(:body).first
    end

    def ordered_fields_hash(namespace_type)
      # we check types first as its the main source of data, except for the Request type which lives in elements
      if parser.types.fetch(namespace_type, nil)
        parser.types.fetch(namespace_type).fetch(:elements)
      else
        parser.elements.fetch(namespace_type).fetch(:type).fetch(:elements)
      end
    end

    def namespace_and_type_from_name(all_attributes, type_name)
      all_attributes.fetch(type_name).fetch(:type)
    end

    def base_type_name(elements, type_name)
      return nil if type_name == BingAdsRubySdk.type_key

      elements.fetch(type_name).fetch(:base_type_name, type_name)
    end

    def self.prefix_and_name(wsdl, type_name)
      wsdl.types.fetch(type_name).prefix_and_name
    end

    private

    attr_reader :parser
  end
end
