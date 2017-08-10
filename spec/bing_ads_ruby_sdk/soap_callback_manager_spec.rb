# frozen_string_literal: true

require 'bing_ads_ruby_sdk/soap_callback_manager'
require 'spec_helper'

RSpec.describe BingAdsRubySdk::SoapCallbackManager do
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

  describe '::before_build' do
    let(:elements) do
      campaign_elements = {
        'Campaign' => double(LolSoap::WSDL::Element, name: 'Campaigns', type: LolSoap::WSDL::NullType.new)
      }

      campaigns_type = double(LolSoap::WSDL::Type, name: 'ArrayOfCampaign', elements: campaign_elements)

      {
        'AccountId' => LolSoap::WSDL::NullElement.new,
        'Campaigns' => double(LolSoap::WSDL::Element, name: 'Campaigns', type: campaigns_type),
      }
    end

    let(:type) do
      LolSoap::WSDL::Type.new('ns0:', nil, elements, [])
    end

    let(:hashes_to_convert) do
      [
        {
          :args=>["173003592"],
          :name=>"account_id"
        },
        {
          :args=>[],
          :sub_hash=> {
            :campaign=> {
              :name=> "Acceptance Test Campaign bca26dff-2466-4829-8bd1-69ff6b147bd9",
              :daily_budget=>10,
              :budget_type=>"DailyBudgetStandard",
              :time_zone=>"BrusselsCopenhagenMadridParis",
              :description=>"This campaign was automatically generated in a test"
            }
          },
          :name=>"campaigns"
        }
      ]
    end

    subject(:call_method) { described_class.before_build(hashes_to_convert, type) }

    context 'when the input element name fuzzy matches the WSDL name' do
      before do
        allow(described_class).to receive(:mark_null_types_with_nil)
        call_method
      end

      let(:elements) do
        {
          'CamelCase' => LolSoap::WSDL::NullElement.new,
          'With_Underscore' => LolSoap::WSDL::NullElement.new,
          'Oneword' => LolSoap::WSDL::NullElement.new,
        }
      end
      let(:hashes_to_convert) do
        [
          { name: 'camel_case' },
          { name: 'with_underscore' },
          { name: 'one_word' },
        ]
      end

      it 'should be mapped to the WSDL element name' do
        expect(hashes_to_convert).to match_array(
                          [
                            { name: 'CamelCase' },
                            { name: 'With_Underscore' },
                            { name: 'Oneword' },
                          ]
                        )
      end
    end

    it 'should order the request data following the WSDL'

    it 'should mark null types with a nil attribute'
  end

  describe '::after_children_hash' do
    let(:input_hash) do
      {
        'FirstKey' => '',
        'Second' => '',
        'Thirdkey' => '',
      }
    end

    let(:keys) { input_hash.keys }
    before { described_class.after_children_hash(input_hash) }

    context 'when a key contains an array of longs' do
      let(:input_hash) do
        {
          'Key' => { long: [1] }
        }
      end

      it 'should convert long values to integer' do
        expect(input_hash[:key]).to eq [1]
      end
    end

    it 'should convert CamelCase hash to symbols' do
      expect(keys).to match_array(%i(first_key second thirdkey))
    end
  end
end
