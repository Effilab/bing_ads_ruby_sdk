require 'spec_helper'
require 'fixtures'

module BingAdsRubySdk
  RSpec.describe AbstractType do
    let(:wsdl) { Fixtures.lol_campaign_management.wsdl }
    let(:abstract_map) { Fixtures.api_config['ABSTRACT'] }

    before do
      SoapCallbackManager.register_callbacks(abstract_map)
      described_class.wsdl = wsdl
    end

    describe '.builder' do
      it 'changes the args' do
        expect(
          described_class.builder(
            [{ args: ['Montreuil'], name: 'location_criterion' }], nil, nil
          ).first
        ).to include(
          args: ['Montreuil', { 'xsi:type' => 'ns0:LocationCriterion' }],
          name: 'Criterion'
        )
      end

      it 'keeps the args' do
        expect(
          described_class.builder(
            [{ args: ['pomme'], name: 'fruit' }], nil, nil
          ).first
        ).to include(args: ['pomme'], name: 'fruit')
      end
    end
  end
end
