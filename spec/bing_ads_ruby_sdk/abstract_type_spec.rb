require 'spec_helper'
require 'fixtures'

module BingAdsRubySdk
  RSpec.describe AbstractType do
    let(:wsdl) { Fixtures.lol_campaign_management }
    let(:abstract_map) { Fixtures.api_config['ABSTRACT']['campaign_management'] }
    let(:subject) { described_class.new(wsdl, abstract_map) }

    describe '.with' do
      it { expect(subject.with('AddConversionGoals') {}).to eq [] }
    end
  end
end
