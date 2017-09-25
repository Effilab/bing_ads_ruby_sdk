require 'spec_helper'
require 'fixtures'

module BingAdsRubySdk
  # TODO : reafactor this or the code
  class Api
    def env_for(version)
      @cache_path = Dir.tmpdir
      Fixtures.api_config
    end
  end

  RSpec.describe Api do
    subject do
      described_class.new(environment: :test)
    end

    it { expect(subject.campaign_management).to be_instance_of(BingAdsRubySdk::Service) }
    it { expect(subject.campaign_management).to respond_to(:add_ads) }

    describe '.header' do
      it { expect(subject.header).to be_instance_of(BingAdsRubySdk::Header) }
    end

    describe '.customer' do
      it { expect(subject).to respond_to(:customer) }
    end
  end
end
