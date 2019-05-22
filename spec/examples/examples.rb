# frozen_string_literal: true

require 'securerandom'

module Examples
  class << self

    def random
      SecureRandom.hex
    end

    def build_api
      BingAdsRubySdk::Api.new(
        developer_token: developer_token,
        client_id: client_id,
        oauth_store: store
      ).tap do |api|
        if account_id && customer_id
          api.set_customer(
            customer_id: customer_id,
            account_id: account_id
          )
        end
      end
    end

    def client_id
      # you have to fill this in with data from bing
    end

    def developer_token
      # you have to fill this in with data from bing
    end

    def parent_customer_id
      # you have to fill this in with data from bing
    end

    def customer_id
      # you have to fill this in with data you get after running 1_customer folder
    end

    def account_id
      # you have to fill this in with data you get after running 1_customer folder
    end

    def uet_tag_id
      # you have to fill this in with data you get after running 2_with_customer folder
    end

    def campaign_id
      # you have to fill this in with data you get after running 2_with_customer folder
    end

    def conversion_goal_id
      # you have to fill this in with data you get after running 3_with_uet_tag folder
    end

    def ad_group_id
      # you have to fill this in with data you get after running 5_with_campaign folder
    end

    def store
      ::BingAdsRubySdk::OAuth2::FsStore.new(store_filename)
    end

    def store_filename
      ENV.fetch('BING_STORE_FILENAME')
    end
  end
end

RSpec.shared_context 'use api' do
  let(:random) { Examples.random }
  let(:api) { Examples.build_api }
end
