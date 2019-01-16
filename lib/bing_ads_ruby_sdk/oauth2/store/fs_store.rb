require 'json'

module BingAdsRubySdk
  module OAuth2
    module Store
      # Oauth2 token default non-encrypted File System store
      class FsStore
        # @param token_key [String] the uniq token_key to identify stored token.
        def initialize(token_key)
          @token_key = token_key
        end

        # Writes the token to file
        # @return [File] if the file was written (doesn't mean the token is).
        # @return [nil] if the token_key don't exist.
        def write(value)
          return nil unless file_name
          File.open(file_name, 'w+') { |f| JSON.dump(value, f) }
        end

        # Reads the token from file
        # @return [Hash] if the token information that was stored.
        # @return [nil] if the file doesn't exist.
        def read
          return nil unless File.file?("./#{file_name}")
          JSON.parse(IO.read(file_name))
        end

        private

        attr_reader :token_key

        # @return [String]
        def file_name
          token_key
        end
      end
    end
  end
end
