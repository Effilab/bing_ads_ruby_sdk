module BingAdsRubySdk
  module Services
    class Json
      def initialize(client:, auth_handler:)
        @client = client
        @auth_handler = auth_handler
      end

      def call(operation, message)
        JSON.parse(post_message(operation, message).body, symbolize_names: true)
      end

      private

      attr_reader :client, :auth_handler

      def post_message(operation, message)
        client[operation].post(
          format_message(message).to_json,
          authorization: "Bearer #{auth_handler.fetch_or_refresh}"
        )
      end

      def format_message(message)
        BingAdsRubySdk::Preprocessors::Camelize.new(message).call
      end
    end
  end
end
