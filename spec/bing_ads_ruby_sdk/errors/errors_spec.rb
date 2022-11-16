# frozen_string_literal: true

RSpec.describe BingAdsRubySdk::Errors::ApplicationFault do
  describe '#fault_hash' do
    context 'when creating an instance' do
      subject(:create_instance) { described_class.new({ details: nil }) }

      it 'instantiates without raising an exception' do
        expect { create_instance }.not_to raise_error
      end
    end
  end
end
