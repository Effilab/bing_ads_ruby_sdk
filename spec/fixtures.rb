class Fixtures
  class << self
    def api_config(version: :v11)
      YAML.load_file(
        File.join(__dir__, 'fixtures', "#{version}.yml")
      )
    end

    def lol_campaign_management
      LolSoap::Client.new(
        File.read(
          open(
            File.join(__dir__, 'fixtures', 'CampaignManagementService.wsdl')
          )
        )
      )
    end
  end
end
