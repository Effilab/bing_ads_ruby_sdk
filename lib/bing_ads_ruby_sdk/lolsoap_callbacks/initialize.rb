require 'bing_ads_ruby_sdk/utils'

# Modify the request data before it is sent via the SOAP client
request_callback = LolSoap::Callbacks.new
request_callback.for('hash_params.before_build') << lambda do |args, node, type|

  matcher = type.elements.keys.map { |name| name.tr('_', '').downcase }

  args.each do |h|
    if h[:name] == 'advertiser_account'
      # Override serialization of the Account data type because the WSDL definition
      # doesn't specify a rule that requires that the type be AdvertiserAccount
      node.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
      h[:args] << { 'xsi:type' => 'ns0:AdvertiserAccount' }
      h[:name] = 'Account'
    else
      # @todo: add comment documentation here
      found_at = matcher.index(h[:name].tr('_', '').downcase)
      h[:name] = type.elements.keys[found_at] if found_at
    end
  end

  # @todo: add comment documentation here
  args.sort_by! { |h| type.elements.keys.index(h[:name]) || 1 / 0.0 }
end

# Modify the response data whilst it is being processed by the SOAP client
response_callback = LolSoap::Callbacks.new
response_callback.for('hash_builder.after_children_hash') << lambda do |hash, node, type|
  hash.keys.each do |k|
    val = hash.delete(k)

    # Convert values of type long to integer
    # TODO : use the type from wsdl instead ?
    val = val[:long].map(&:to_i) if val.is_a?(Hash) && val[:long].is_a?(Array)

    # Add the value to the return hash using a symbol as a key instead of the
    # default CamelCase string
    hash[BingAdsRubySdk::Utils.snakize(k).to_sym] = val
  end
end
