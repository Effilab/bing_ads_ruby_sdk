RSpec.describe BingAdsRubySdk::Header do
  let(:oauth_store) { double(:oauth_store) }
  let(:subject) { described_class.new(developer_token: '123abc', client_id: '1a-2b-3c', store: oauth_store) }
  let(:auth_handler) do
    double(:auth_handler, fetch_or_refresh: 'yes/we/can')
  end

  before do
    expect(::BingAdsRubySdk::OAuth2::AuthorizationHandler).to receive(:new).with(
      developer_token: '123abc',
      client_id: '1a-2b-3c',
      store: oauth_store
    ).and_return auth_handler
  end

  describe '.content' do
    it do
      expect(subject.content).to eq(
        "AuthenticationToken" => 'yes/we/can',
        "DeveloperToken" =>      '123abc',
        "CustomerId" =>          nil,
        "CustomerAccountId" =>   nil
      )
    end

    it 'sets customer' do
      subject.set_customer(customer_id: 777, account_id: 666 )

      expect(subject.content).to eq(
        "AuthenticationToken" => 'yes/we/can',
        "DeveloperToken" =>      '123abc',
        "CustomerId" =>          777,
        "CustomerAccountId" =>   666
      )
    end
  end
end
