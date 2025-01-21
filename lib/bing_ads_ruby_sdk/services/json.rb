module BingAdsRubySdk
  module Services
    class Json
      # Request struct
      Request = Struct.new(:url, :headers, :content, keyword_init: true)
      def initialize(base_url:, headers:, auth_handler:)
        @client = BingAdsRubySdk::HttpClient
        @base_url = base_url
        @headers = headers
        @auth_handler = auth_handler
      end

      def call(operation, message)
        response = client.post(request(operation, message))
        
        JSON.parse(response, symbolize_names: true)
      end

      private

      attr_reader :client, :base_url, :headers, :auth_handler

      def request(operation, message)
        Request.new(
          url: "#{base_url}#{operation}",
          headers: headers.merge(
            authorization: "Bearer #{auth_handler.fetch_or_refresh}"
          ),
          content: format_message(message).to_json
        )
      end

      def format_message(message)
        BingAdsRubySdk::Preprocessors::Camelize.new(message).call
      end
    end
  end
end
