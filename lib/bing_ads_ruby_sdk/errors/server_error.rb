# frozen_string_literal: true

module BingAdsRubySdk
  module Errors
    # Base exception class for reporting API errors
    class ServerError < ::StandardError
      def initialize(server_error)
        super "Server raised error #{server_error.body}"
      end
    end
  end
end
