require 'spec_helper'
require 'fixtures'

module BingAdsRubySdk
  Configuration::ENVIRONMENTS = %i[test].freeze
  Configuration::VERSIONS     = %i[v11].freeze
  Configuration::CACHE_BASE   = Dir.tmpdir
  Configuration::CONF_PATH    = File.join(__dir__, '..', 'fixtures')

  RSpec.describe Api do
    before(:all) { BingAdsRubySdk::Cache.build }
    after(:all)  { BingAdsRubySdk::Cache.clear }

    subject do
      described_class.new(environment: :test)
    end

    it { expect(subject.campaign_management).to be_instance_of(BingAdsRubySdk::Service) }
    it { expect(subject.campaign_management).to respond_to(:add_ads) }

    describe '.header' do
      it { expect(subject.header).to be_instance_of(BingAdsRubySdk::Header) }

      describe '.content' do
        it 'inits properly so the content is available' do
          expect(subject.header.content).to be_a(Hash)
        end
      end
    end

    describe '.customer' do
      it { expect(subject).to respond_to(:customer) }
    end
  end
end
