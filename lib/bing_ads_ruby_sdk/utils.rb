module BingAdsRubySdk
  class Utils
    class << self
      # Convert CamelCase string to snake_case
      def snakize(string)
        string.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .tr('-', '_')
              .downcase
      end
    end
  end
end
