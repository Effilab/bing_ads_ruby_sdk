require 'json'

module BingAdsRubySdk
  module OAuth2
    # Oauth2 token default non-encrypted File System store
    # You must define the attr_reader and all methods in your own Store definition
    class FsStore
      attr_reader :token_key

      # @param token_key [String] the uniq token_key to identify stored token.
      def initialize(token_key)
        @token_key = token_key
      end

      # Writes the token to file
      # @return [File] if the file was written (doesn't mean the token is).
      # @return [nil] if the token_key don't exist.
      def write(value)
        return nil unless token_key
        File.open(".#{token_key}", 'w+') { |f| JSON.dump(value, f) }
      end

      # Reads the token from file
      # @return [Hash] if the token information that was stored.
      # @return [nil] if the file doesn't exist.
      def read
        return nil unless File.file?("./.#{token_key}")
        JSON.parse(IO.read("./.#{token_key}"))
      end
    end
  end
end
