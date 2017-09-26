require 'byebug'

module BingAdsRubySdk
  class AbstractType
    class << self
      @abstract_types = {}

      attr_accessor :abstract_types, :wsdl

      def builder(args, _node, _type)
        args.each do |h|
          abstract_types.each do |abstract, concretes|
            concretes.each do |concrete|
              # Skip this type if the argument name does not match the abstract type name
              next unless concrete.tr('_', '').casecmp(h[:name].tr('_', '')).zero?
              change_args(h, abstract, concrete)
            end
          end
        end
      end

      def change_args(h, abstract, concrete)
        BingAdsRubySdk.logger.debug("Building concrete type : #{concrete}")
        h[:args] << { 'xsi:type' => wsdl.types[concrete].prefix_and_name }
        h[:name] = abstract
        h[:sub_type] = wsdl.types[concrete]
      end

      def register
        SoapCallbackManager.abstract_callback.for('hash_params.before_build') << method(:builder)
      end
    end
  end
end
