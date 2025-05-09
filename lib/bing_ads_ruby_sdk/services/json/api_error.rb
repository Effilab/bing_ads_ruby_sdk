module BingAdsRubySdk
  module Services
    module Json
      # Used to handle the response from the Bing Ads API
      class ApiError < StandardError
        ERROR_LIMIT = 2

        attr_reader :details
        attr_reader :category

        # @param category [Symbol] the category of the error
        # @example :PartialErrors
        # @param errors [Array<Hash>] the list of errors
        # @example [{ Index: 0, Code: "CampaignServiceSharedListIdInvalid", Message: "Error" }]
        def initialize(category, errors)
          @category = category
          @details = errors

          super("#{category}: #{format_message(errors)}")
        end

        private

        def format_message(errors)
          message = errors.take(ERROR_LIMIT).map { |error| format_error(error) }.join(", ")

          message = "#{message} (+#{errors.size - ERROR_LIMIT} not shown)" if errors.size > ERROR_LIMIT

          message
        end

        def format_error(error)
          index = error[:Index] ? "#{error[:Index]}: " : ""

          "#{index}#{error[:Code]} - #{error[:Message]}"
        end
      end
    end
  end
end
