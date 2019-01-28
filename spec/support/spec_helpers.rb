module SpecHelpers
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

  def self.wrapper(service, action_name)
    soap_client(service).wsdl_wrapper(action_name)
  end

  def self.default_store
    ::BingAdsRubySdk::OAuth2::FsStore.new(ENV['BING_STORE_FILENAME'])
  end

  # default fixture for now is standard.xml but door is open to get more use cases
  def self.xml_path_for(service, action, filename, request = true)
    if request
      File.join(BingAdsRubySdk.root_path, 'spec', 'fixtures', service.to_s, action, "#{filename}.xml")
    else
      File.join(BingAdsRubySdk.root_path, 'spec', 'fixtures', service.to_s, action, "#{filename}_response.xml")
    end
  end
end