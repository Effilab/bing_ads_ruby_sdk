# frozen_string_literal: true

require "bing_ads_ruby_sdk/services/json/base"

module BingAdsRubySdk
  module Services
    module Json
      class Reporting < Base
        def submit_generate_report(payload)
          post("GenerateReport/Submit", payload)
        end

        def poll_generate_report(payload)
          post("GenerateReport/Poll", payload)
        end

        def download_file(url:, stream: false)
          stream ? client.get(url, stream: true) : client.get(url)
        end
      end
    end
  end
end
