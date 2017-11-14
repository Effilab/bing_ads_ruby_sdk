require 'bing_ads_ruby_sdk/utils'
require 'bing_ads_ruby_sdk/exceptions'

module BingAdsRubySdk
  # Handles of LolSoap callbacks
  # FIXME : that should be splitted in smaller classes in a callbacks folder
  class SoapCallbackManager
    class << self
      def register_callbacks
        # Modify the request data before it is sent via the SOAP client
        # Modify the response data whilst it is being processed by the SOAP client
        LolSoap::Callbacks.register(
          {
            "hash_params.before_build" => [request_callback_lambda],
            "hash_builder.after_children_hash" => [response_callback_lambda],
          }
        )
      end

      def request_callback_lambda
        lambda do |args, _node, type|
          before_build(args, type)
        end
      end

      def response_callback_lambda
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
          # FIXME : missing element would be more efficient and cleaner by populating an error hash instead of raising
          # More efficient cause raising will give you a hint only on first missing element
          # Cleaner cause you'll see it untangles the conditions
          if found_at
            name = el_keys[found_at]
            # Abstract types
            if type.elements[name].respond_to?(:name) && name != type.elements[name].name
              hash[:name]     = type.elements[name].name
              hash[:sub_type] = type.elements[name].type
              hash[:args] << { 'xsi:type' => type.elements[name].type.prefix_and_name }
            else
              hash[:name] = name
            end

          elsif !type.is_a?(LolSoap::WSDL::NullType) && type.prefix_and_name == 'soap:Header'
            BingAdsRubySdk.logger.info(get_type_mismatch_message(hash, type))
          else
            raise ElementMismatch, get_type_mismatch_message(hash, type)
          end
        end
      end

      def get_type_mismatch_message(hash, type)
        return "#{hash[:name]} not permitted on element" if type.is_a?(LolSoap::WSDL::NullType)

        "#{hash[:name]} not found in #{type.prefix_and_name}. Possible fields #{type.elements.keys.join(', ')}"
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
