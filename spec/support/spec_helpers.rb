module SpecHelpers
  def self.wrapper(wsdl_name, action_name)
    BingAdsRubySdk::WsdlOperationWrapper.new(parser(wsdl_name), action_name)
  end

  def self.parser(name)
    LolSoap::WSDLParser.parse(File.read(wsdl_path(name)))
  end

  def self.wsdl_path(name)
    File.join(BingAdsRubySdk.root_path, 'lib', 'bing_ads_ruby_sdk', 'wsdl', BingAdsRubySdk::DEFAULT_SDK_VERSION.to_s, 'test', "#{name}.xml")
  end

  def self.default_store
    ::BingAdsRubySdk::OAuth2::FsStore.new(ENV['BING_TOKEN_NAME'])
  end
end