# frozen_string_literal: true

module BingAdsRubySdk
  class WsdlOperationWrapper

    attr_reader :request_namespace_type

    def initialize(parser, operation_name)
      @parser = parser
      @request_namespace_type = parser.operations.fetch(operation_name).fetch(:input).fetch(:body).first
    end

    # element_type:
    def ordered_fields_hash(namespace_type)
      # we check types first as its the main source of data, except for the Request type which lives in elements
      if parser.types.fetch(namespace_type, nil)
        parser.types.fetch(namespace_type).fetch(:elements)
      else
        parser.elements.fetch(namespace_type).fetch(:type).fetch(:elements)
      end
    end

    def namespace_and_type_from_name(all_attributes, type_name, real_type_name)
      namespace_type = all_attributes.fetch(type_name).fetch(:type)
      if real_type_name
        # we need to get the namespace, then use the real_type_name
        [namespace_type.first, real_type_name]
      else
        namespace_type
      end
    end

    def self.prefix_and_name(wsdl, type_name)
      wsdl.types.fetch(type_name).prefix_and_name
    end

    private

    attr_reader :parser
  end
end
