require 'json'

module BingAdsRubySdk
  module OAuth2
    # Oauth2 token default non-encrypted File System store
    class FsStore
      attr_reader :token_key

      def initialize(token_key)
        @token_key = token_key
      end

      # Writes the token to file
      # @return [File] An instance of the file that the token was written to
      def write(value)
        return nil unless token_key
        JSON.dump(value, File.open(".#{token_key}", 'w+'))
      end

      # Reads the token from file
      # @return [Hash,nil] The token information that was stored in the file
      #   or nil if the file doesn't exist
      def read
        return nil unless File.file?("./.#{token_key}")
        JSON.parse(IO.read("./.#{token_key}"))
      end
    end
  end
end
