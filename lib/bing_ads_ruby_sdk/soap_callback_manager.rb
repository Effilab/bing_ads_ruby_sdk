# frozen_string_literal: true

require 'bing_ads_ruby_sdk/utils'

module BingAdsRubySdk
  # Handles of LolSoap callbacks
  class SoapCallbackManager
    class << self
      attr_accessor :abstract_callback, :request_callback, :response_callback
    end

    def self.register_callbacks
      # Instantiate the callbacks in the order they need to be triggered
      self.abstract_callback = LolSoap::Callbacks.new
      self.request_callback  = LolSoap::Callbacks.new
      self.response_callback = LolSoap::Callbacks.new

      # Modify the request data before it is sent via the SOAP client
      SoapCallbackManager.request_callback
                    .for('hash_params.before_build') <<
        lambda do |args, _node, type|
          before_build(args, type)
        end

      # Modify the response data whilst it is being processed by the SOAP client
      SoapCallbackManager.response_callback
                    .for('hash_builder.after_children_hash') <<
        lambda do |hash, _node, _type|
          after_children_hash(hash)
        end
    end

    def self.before_build(args, type)
      convert_element_names(args, type)

      # Sorts the request data on the wsdl order
      args.sort_by! { |h| type.elements.keys.index(h[:name]) || 1 / 0.0 }

      mark_null_types_with_nil(args, type)
    end

    def self.after_children_hash(hash)
      hash.keys.each do |k|
        val = hash.delete(k)

        # Convert values of type long to integer.
        # Removes unecessary :long hash key.
        # TODO : use the type from wsdl instead ?
        if val.is_a?(Hash) && val[:long].is_a?(Array)
          val = val[:long].map(&:to_i)
        end

        # Add the value to the return hash using a symbol as a key instead
        # of the default CamelCase string
        hash[BingAdsRubySdk::Utils.snakize(k).to_sym] = val
      end
    end

    def self.convert_element_names(argument_hashes, type)
      # Fuzzy matching for element names
      matcher = type.elements.keys.map { |name| name.tr('_', '').downcase }

      argument_hashes.each do |h|
        found_at = matcher.index(h[:name].tr('_', '').downcase)
        h[:name] = type.elements.keys[found_at] if found_at
      end
    end

    def self.null_type_fields(args, type)
      args.select do |arg|
        type.elements[arg[:name]] &&
          type.elements[arg[:name]].type.is_a?(LolSoap::WSDL::NullType) &&
          arg[:args].compact.empty?
      end
    end

    def self.mark_null_types_with_nil(args, type)
      null_type_fields(args, type).each do |arg|
        arg[:args] << { 'xsi:nil' => true }
      end
    end
  end
end
