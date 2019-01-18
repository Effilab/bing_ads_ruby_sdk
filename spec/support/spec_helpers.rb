module SpecHelpers

  def self.configure_gem
    BingAdsRubySdk.configure do |conf|
      conf.log = true
      conf.logger.level = Logger::DEBUG
      conf.pretty_print_xml = true
      conf.filters = ["AuthenticationToken", "DeveloperToken", "CustomerId", "CustomerAccountId"]
    end
  end

  def self.request_xml_for(service, action, filename)
    Nokogiri::XML(File.read(xml_path_for(service, action, filename)))
  end

  def self.response_xml_for(service, action, filename)
    File.read(xml_path_for(service, action, filename, false))
  end

  def self.fake_header
    OpenStruct.new(
      content: {
        "AuthenticationToken" => BingAdsRubySdk::LogMessage::FILTERED,
        "DeveloperToken" =>      BingAdsRubySdk::LogMessage::FILTERED,
        "CustomerId" =>          BingAdsRubySdk::LogMessage::FILTERED,
        "CustomerAccountId" =>   BingAdsRubySdk::LogMessage::FILTERED
    })
  end

  def self.soap_client(service, header = fake_header)
    BingAdsRubySdk::SoapClient.new(
      service_name: service,
      version: BingAdsRubySdk::DEFAULT_SDK_VERSION,
      environment: 'test',
      header: header
    )
  end

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

  def self.xml_path_for(service, action, filename, request = true)
    if request
      File.join(BingAdsRubySdk.root_path, 'spec', 'fixtures', service.to_s, action, "#{filename}.xml")
    else
      File.join(BingAdsRubySdk.root_path, 'spec', 'fixtures', service.to_s, action, "#{filename}_response.xml")
    end
  end
end