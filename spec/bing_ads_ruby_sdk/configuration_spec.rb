require 'spec_helper'

module BingAdsRubySdk
  Configuration::ENVIRONMENTS = %i[test].freeze
  Configuration::VERSIONS     = %i[v11].freeze
  Configuration::CACHE_BASE   = Dir.tmpdir
  Configuration::CONF_PATH    = File.join(__dir__, '..', 'fixtures')

  RSpec.describe Configuration do
    subject do
      described_class.new(version: :v11, environment: :test)
    end

    it { expect(subject.data.keys).to eq %w[ABSTRACT TEST] }
    it { expect(subject.version).to eq :v11 }
    it { expect(subject.environment).to eq :test }
    it do
      expect(
        subject.cache_path
      ).to eq File.join(Configuration::CACHE_BASE, '.cache', 'v11', 'test')
    end
    it { expect(subject.abstract.keys).to eq ['campaign_management'] }
    it do
      expect(
        subject.services
      ).to eq('campaign_management' => './spec/fixtures/CampaignManagementService.wsdl')
    end

    describe '.all' do
      it { expect { |block| Configuration.all(&block) }.to yield_with_args(BingAdsRubySdk::Configuration) }
      it { expect { |block| Configuration.all(&block) }.to yield_control.once }
    end
  end
end
