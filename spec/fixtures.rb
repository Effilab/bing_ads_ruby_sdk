require "bing_ads_ruby_sdk/wsdl_parser"

class Fixtures
  class << self
    def api_config(version: :v11)
      YAML.load_file(
        File.join(__dir__, 'fixtures', "#{version}.yml")
      )
    end

    # FIXME : tests would be a lot faster by slimming a lot this wsdl
    def wsdl_file
      File.read(
        open(
          File.join(__dir__, 'fixtures', 'CampaignManagementService.wsdl')
        )
      )
    end

    def lol_campaign_management
      parser = BingAdsRubySdk::WSDLParser.new(
        Fixtures.api_config['ABSTRACT']['campaign_management'],
        wsdl_file
      ).parser
      LolSoap::Client.new(LolSoap::WSDL.new(parser))
    end
  end
end
