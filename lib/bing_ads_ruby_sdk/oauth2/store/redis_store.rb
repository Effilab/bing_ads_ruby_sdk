require "json"

module BingAdsRubySdk
  module OAuth2
    module Store
      class RedisStore
        class << self
          # This should be set before using the SDK.
          # See the README.md
          attr_accessor :redis
        end

        attr_reader :token_key
        REDIS_KEY = "bing-ads-tokens"

        def initialize(token_key)
          unless self.redis
            raise "You need to provide a redis connection. Check the README.md", StandardError
          end

          @token_key = token_key
        end

        # Writes the token to redis
        # @return [File] if the value was written (doesn't mean the token is).
        # @return [nil] if the token_key don't exist.
        def write(value)
          return nil unless token_key

          redis.hset(REDIS_KEY, token_key, JSON.generate(value))
        end

        # Reads the token from redis
        # @return [Hash] if the token information that was stored.
        # @return [nil] if the value doesn't exist.
        def read
          token_as_json = redis.hget(REDIS_KEY, token_key)
          return nil unless token_as_json

          JSON.parse(token_as_json)
        end

        def redis
          self.class.redis
        end
      end
    end
  end
end
