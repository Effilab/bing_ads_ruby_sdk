# frozen_string_literal: true

require 'rails/generators'

module BingAdsRubySdk
  module Generators
    # Installs BingAdsRubySdk config
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __dir__)

      desc 'Creates a config file.'

      def copy_config
        template 'bing_ads_ruby_sdk_config.rb', "#{Rails.root}/config/initializers/bing_ads_ruby_sdk.rb"
      end
    end
  end
end
