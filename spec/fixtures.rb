class Fixtures
  class << self
    def api_config(version: :v11)
      YAML.load_file(
        File.join(__dir__, 'fixtures', "#{version}.yml")
      )
    end
  end
end
