require 'bing_ads_ruby_sdk/utils'

request_callback = LolSoap::Callbacks.new
request_callback.for('hash_params.before_build') << lambda do |args, node, type|
  matcher = type.elements.keys.map { |name| name.tr('_', '').downcase }
  args.each do |h|
    if h[:name] == 'advertiser_account'
      node.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
      h[:args] << { 'xsi:type' => 'ns0:AdvertiserAccount' }
      h[:name] = 'Account'
    else
      found_at = matcher.index(h[:name].tr('_', '').downcase)
      h[:name] = type.elements.keys[found_at] if found_at
    end
  end
  args.sort_by! { |h| type.elements.keys.index(h[:name]) || 1 / 0.0 }
end

response_callback = LolSoap::Callbacks.new
response_callback.for('hash_builder.after_children_hash') << lambda do |hash, node, type|
  hash.keys.each do |k|
    val = hash.delete(k)
    # TODO : use the type from wsdl instead ?
    val = val[:long].map(&:to_i) if val.is_a?(Hash) && val[:long].is_a?(Array)
    hash[BingAdsRubySdk::Utils.snakize(k).to_sym] = val
  end
end
