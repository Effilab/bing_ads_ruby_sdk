require 'spec_helper'

module BingAdsRubySdk
  RSpec.describe Header do
    let(:token) do
      double('subject token').tap do |token|
        allow(token).to receive(:fetch_or_refresh) { 'yes/we/can' }
      end
    end

    let(:subject) do
      described_class.new(
        { developer_token: '123abc',
          client_id:       '1a-2b-3c' },
        token
      )
    end

    describe '.content' do
      it do
        expect(subject.content).to eq(
          authentication_token: 'yes/we/can',
          developer_token:      '123abc',
          customer_id:          nil,
          customer_account_id:  nil
        )
      end

      it 'sets customer' do
        subject.customer = { id: 777, account_id: 666 }

        expect(subject.content).to eq(
          authentication_token: 'yes/we/can',
          developer_token:      '123abc',
          customer_id:          777,
          customer_account_id:  666
        )
      end
    end
  end
end
