require 'bing_ads_ruby_sdk/utils'
require 'bing_ads_ruby_sdk/exceptions'
require 'bing_ads_ruby_sdk/callbacks/abstract_type'

module BingAdsRubySdk
  # Handles of LolSoap callbacks
  class SoapCallbackManager
    class << self
      attr_accessor :request_callback, :response_callback

      def register_callbacks
        # A bit hacky, but let's think about this
        Thread.current[:registered_callbacks] = []

        # Instantiate the callbacks in the order they need to be triggered
        self.request_callback = LolSoap::Callbacks.new
        self.response_callback = LolSoap::Callbacks.new

        # Modify the request data before it is sent via the SOAP client
        request_callback
          .for('hash_params.before_build') <<
          lambda do |args, _node, type|
            before_build(args, type)
          end

        # Modify the response data whilst it is being processed by the SOAP client
        response_callback
          .for('hash_builder.after_children_hash') <<
          lambda do |hash, _node, _type|
            after_children_hash(hash)
          end
      end

      def before_build(args, type)
        convert_element_names(args, type)

        # Sorts the request data on the wsdl order
        args.sort_by! { |h| type.elements.keys.index(h[:name]) || 1 / 0.0 }

        mark_null_types_with_nil(args, type)
      end

      def after_children_hash(hash)
        hash.keys.each do |key|
          value = hash.delete(key)

          # Convert values of type long to integer.
          # Removes unnecessary :long hash key.
          # TODO : use the type from wsdl instead ?
          if value.is_a?(Hash) && value[:long].is_a?(Array)
            value = value[:long].map(&:to_i)
          end

          # Add the value to the return hash using a symbol as a key instead
          # of the default CamelCase string
          hash[BingAdsRubySdk::Utils.snakize(key).to_sym] = value
        end
      end

      def convert_element_names(argument_hashes, type)
        # Fuzzy matching for element names
        el_keys = type.elements.keys
        matcher = el_keys.map { |name| name.tr('_', '').downcase }

        argument_hashes.each do |hash|
          found_at = matcher.index(hash[:name].tr('_', '').downcase)
          if found_at
            name = el_keys[found_at]
            hash[:name] = type.elements[name].name
            if name != type.elements[name].name
              hash[:sub_type] = type.elements[name].type
              hash[:args] << { 'xsi:type' => type.elements[name].type.prefix_and_name }
            end

          elsif type.prefix_and_name == 'soap:Header'
            BingAdsRubySdk.logger.info(
              "#{hash[:name]} not found in #{type.prefix_and_name}."\
              "Possible fields #{el_keys.join(', ')}"
            )

          else
            byebug
            raise ElementMismatch, "#{hash[:name]} not found in #{type.prefix_and_name}."\
                                   "Possible fields #{el_keys.join(', ')}"
          end
        end
      end

      def null_type_fields(args, type)
        args.select do |arg|
          type.elements[arg[:name]] &&
            type.elements[arg[:name]].type.is_a?(LolSoap::WSDL::NullType) &&
            arg[:args].compact.empty?
        end
      end

      def mark_null_types_with_nil(args, type)
        null_type_fields(args, type).each do |arg|
          arg[:args] << { 'xsi:nil' => true }
        end
      end
    end
  end
end
