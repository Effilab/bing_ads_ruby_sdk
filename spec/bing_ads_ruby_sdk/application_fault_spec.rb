# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BingAdsRubySdk::Errors::ApplicationFault do
  describe '#fault_hash' do
    context 'when the details are not populated' do
      subject(:fault_instance) { described_class.new({ details: nil }) }

      it 'should raise an exception if fault_hash called on the base class' do
        expect { fault_instance.fault_hash }.to raise_error 'No Detail element in API response'
      end
    end
  end
end
