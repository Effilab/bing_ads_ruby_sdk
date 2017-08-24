module BingAdsRubySdk
  class AbstractType
    attr_reader :wsdl, :abstract_map

    def initialize(wsdl, abstract_map)
      @wsdl = wsdl
      @abstract_map = abstract_map || {}
    end

    def builder(args, node, _)
      args.each do |h|
        @abstract_types.each do |concrete, abstract|
          # Skip this type if the argument name does not match the abstract type name
          next unless concrete.tr('_', '').casecmp(h[:name].tr('_', '')).zero?

          change_args(h, abstract, concrete)
        end
      end
    end

    def change_args(h, abstract, concrete)
      BingAdsRubySdk.logger.debug("Building concrete type : #{concrete}")
      h[:args] << { 'xsi:type' => wsdl.types[concrete].prefix_and_name }
      h[:name] = abstract
      h[:sub_type] = wsdl.types[concrete]
    end

    def with(operation)
      @abstract_types = abstract_map[operation]
      return yield if @abstract_types.nil?

      SoapCallbackManager.abstract_callback.for('hash_params.before_build') << method(:builder)
      yield
      SoapCallbackManager.abstract_callback.for('hash_params.before_build').clear
    end
  end
end
