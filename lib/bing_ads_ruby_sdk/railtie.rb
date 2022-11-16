# frozen_string_literal: true

require 'bing_ads_ruby_sdk'
require 'rails'

module BingAdsRubySdk
  class Railtie < Rails::Railtie
    railtie_name :bing_ads_ruby_sdk

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
