# frozen_string_literal: true

module BingAdsRubySdk
  module Errors
    # Base exception class for reporting API errors
    class ServerError < ::StandardError
      attr_accessor :message

      def initialize(server_error)
        @message = "Server raised error #{server_error.body}"
      end
    end
  end
end
