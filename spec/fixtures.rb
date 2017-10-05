class Fixtures
  class << self
    def api_config(version: :v11)
      YAML.load_file(
        File.join(__dir__, 'fixtures', "#{version}.yml")
      )
    end

    def lol_campaign_management
      parser = BingAdsRubySdk::WSDLParser.new(
        Fixtures.api_config['ABSTRACT']['campaign_management'],
        File.read(
          open(
            File.join(__dir__, 'fixtures', 'CampaignManagementService.wsdl')
          )
        )
      ).parser
      LolSoap::Client.new(LolSoap::WSDL.new(parser))
    end
  end
end
