# frozen_string_literal: true

RSpec.describe BingAdsRubySdk::Header do
  let(:oauth_store) { double(:oauth_store) }
  let(:client_secret) { 'pa$$w0rd' }
  let(:subject) do
    described_class.new(
      developer_token: '123abc',
      client_id: '1a-2b-3c',
      client_secret: client_secret,
      store: oauth_store
    )
  end
  let(:auth_handler) do
    double(:auth_handler, fetch_or_refresh: 'yes/we/can')
  end

  before do
    expect(::BingAdsRubySdk::OAuth2::AuthorizationHandler).to receive(:new).with(
      developer_token: '123abc',
      client_id: '1a-2b-3c',
      client_secret: client_secret,
      store: oauth_store
    ).and_return auth_handler
  end

  describe '.content' do
    it do
      expect(subject.content).to eq(
        'AuthenticationToken' => 'yes/we/can',
        'DeveloperToken' => '123abc',
        'CustomerId' => nil,
        'CustomerAccountId' => nil,
        'ClientSecret' => client_secret
      )
    end

    context 'without client_secret' do
      let(:client_secret) { nil }
      it do
        expect(subject.content).to eq(
          'AuthenticationToken' => 'yes/we/can',
          'DeveloperToken' => '123abc',
          'CustomerId' => nil,
          'CustomerAccountId' => nil
        )
      end
    end

    it 'sets customer' do
      subject.set_customer(customer_id: 777, account_id: 666)

      expect(subject.content).to eq(
        'AuthenticationToken' => 'yes/we/can',
        'DeveloperToken' => '123abc',
        'CustomerId' => 777,
        'CustomerAccountId' => 666,
        'ClientSecret' => client_secret
      )
    end
  end
end
