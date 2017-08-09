require 'rspec'
require 'bing_ads_ruby_sdk/soap_callback_manager'
require 'lolsoap'

describe BingAdsRubySdk::SoapCallbackManager do
  describe '::register_callbacks' do
    let(:request_callback) { instance_double('LolSoap::Callbacks', for: []) }
    let(:response_callback) { instance_double('LolSoap::Callbacks', for: []) }

    before do
      allow(BingAdsRubySdk).to receive(:request_callback).and_return request_callback
      allow(BingAdsRubySdk).to receive(:response_callback).and_return response_callback

      BingAdsRubySdk::SoapCallbackManager.register_callbacks
    end

    it 'should register the callbacks with Lolsoap' do
      expect(request_callback).to have_received(:for).with('hash_params.before_build')
      expect(response_callback).to have_received(:for).with('hash_builder.after_children_hash')
    end
  end
end
