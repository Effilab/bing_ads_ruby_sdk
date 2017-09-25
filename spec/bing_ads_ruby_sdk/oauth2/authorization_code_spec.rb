require 'spec_helper'

module BingAdsRubySdk
  module OAuth2
    RSpec.describe AuthorizationCode do
      context 'when properly instantiated' do
        let(:token) do
          { access_token:  'yes/we/can',
            refresh_token: 'new/election',
            issued_at:     Time.now.to_s,
            expires_in:    3600 }
        end

        let(:store) do
          double('subject store').tap do |store|
            allow(store).to receive(:new).with('token_effilab-123') { store }
            allow(store).to receive(:read) { token }
          end
        end

        subject do
          described_class.new(
            { developer_token: '123',
              client_id:       'effilab-123' },
            store: store
          )
        end

        it { expect(subject.client).to be_instance_of(Signet::OAuth2::Client) }
        it { expect(subject.client.client_id).to eq('effilab-123') }
        it { expect(subject.fetch_or_refresh).to eq 'yes/we/can' }

        context 'with an expired token' do
          before do
            token[:issued_at] = (Time.now - 7200).to_s
            allow(store).to receive(:write)
            allow(subject.client).to receive(:refresh!).and_wrap_original { |_| token }
          end

          it { expect(subject.fetch_or_refresh).to eq 'yes/we/can' }
        end
      end

    end
  end
end
