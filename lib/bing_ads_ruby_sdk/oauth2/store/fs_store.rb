require 'json'

module BingAdsRubySdk
  module OAuth2
    module Store
      # Oauth2 token default non-encrypted File System store
      # You must define the attr_reader and all methods in your own Store definition
      class FsStore
        class << self
          # This is optionnal:
          # You can provide a .json file with all the configuration.
          attr_accessor :config
        end

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
          File.open(file_name, 'w+') { |f| JSON.dump(value, f) }
        end

        # Reads the token from file
        # @return [Hash] if the token information that was stored.
        # @return [nil] if the file doesn't exist.
        def read
          return nil unless File.file?("./.#{token_key}")
          JSON.parse(IO.read(file_name))
        end

        # FsStore config file
        # @return [String]
        def file_name
          if self.class.config
            self.class.config
          else
            ".#{token_key}"
          end
        end
      end
    end
  end
end
