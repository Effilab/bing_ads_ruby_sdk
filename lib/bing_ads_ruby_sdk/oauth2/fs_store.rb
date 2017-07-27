require 'json'

module BingAdsRubySdk
  module OAuth2
    # Default uncripted File System store
    class FsStore
      attr_reader :token_key

      def initialize(token_key)
        @token_key = token_key
      end

      def write(value)
        return nil unless token_key
        JSON.dump(value, File.open(".#{token_key}", 'w+'))
      end

      def read
        return nil unless File.file?("./.#{token_key}")
        JSON.parse(IO.read("./.#{token_key}"))
      end
    end
  end
end
