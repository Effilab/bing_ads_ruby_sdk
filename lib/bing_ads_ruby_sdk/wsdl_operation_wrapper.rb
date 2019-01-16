module BingAdsRubySdk
  class WsdlOperationWrapper

    attr_reader :request_namespace_type

    def initialize(parser, operation_name)
      @parser = parser
      @request_namespace_type = parser.operations.fetch(operation_name)[:input][:body].first
    end

    # element_type:
    def ordered_fields_hash(namespace_type)
      # we check types first as its the main source of data, except for the Request type which lives in elements
      if parser.types[namespace_type]
        parser.types[namespace_type][:elements]
      else
        parser.elements[namespace_type][:type][:elements]
      end
    end

    def namespace_and_type_from_name(all_attributes, type_name, real_type_name)
      namespace_type = all_attributes[type_name][:type]
      if real_type_name
        # we need to get the namespace, then use the real_type_name
        [namespace_type.first, real_type_name]
      else
        namespace_type
      end
    end

    private

    attr_reader :parser
  end
end
