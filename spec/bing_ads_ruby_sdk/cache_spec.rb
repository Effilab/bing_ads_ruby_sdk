require 'spec_helper'
require 'bing_ads_ruby_sdk/cache'

module BingAdsRubySdk
  RSpec.describe Cache do
    let(:config) { Configuration.new(version: :v11, environment: :test) }
    after { described_class.clear }

    describe '.build and .clear' do
      it do
        described_class.build
        expect(config.cached('campaign_management')).to be_a LolSoap::Client
        described_class.clear
        expect { config.cached('campaign_management') }.to raise_error Errno::ENOENT
      end
    end

    describe '.build and .check' do
      it 'works' do
        described_class.build
        described_class.check
      end

      it 'raises when not there' do
        expect { described_class.check }.to raise_error Errno::ENOENT
      end

      it 'raises when truncated' do
        described_class.build
        File.truncate(File.join(config.cache_path, 'campaign_management'), 10)
        expect { described_class.check }.to raise_error ArgumentError
      end
    end
  end
end
