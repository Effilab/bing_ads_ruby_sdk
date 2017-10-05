# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BingAdsRubySdk::SoapCallbackManager do
  describe '.register_callbacks' do
    let(:request_callback) { instance_double('LolSoap::Callbacks', for: []) }
    let(:response_callback) { instance_double('LolSoap::Callbacks', for: []) }

    before do
      allow(described_class).to receive(:request_callback).and_return request_callback
      allow(described_class).to receive(:response_callback).and_return response_callback

      described_class.register_callbacks({})
    end

    it 'should register the callbacks with Lolsoap' do
      expect(request_callback).to have_received(:for).with('hash_params.before_build')
      expect(response_callback).to have_received(:for).with('hash_builder.after_children_hash')
    end
  end

  describe '.before_build' do
    def non_null_element(name)
      double(LolSoap::WSDL::Element, name: name, type: "#{name}Type")
    end

    let(:null_element) { LolSoap::WSDL::NullElement.new }
    let(:type) { LolSoap::WSDL::Type.new('ns0:', nil, elements, []) }

    before { described_class.before_build(hashes_to_convert, type) }

    context 'when the input element name fuzzy matches the WSDL name' do
      let(:elements) do
        {
          'CamelCase' => non_null_element('CamelCase'),
          'With_Underscore' => non_null_element('With_Underscore'),
          'Oneword' => non_null_element('Oneword')
        }
      end
      let(:hashes_to_convert) do
        [
          { name: 'camel_case', args: [] },
          { name: 'with_underscore', args: [] },
          { name: 'one_word', args: [] }
        ]
      end

      it 'should be mapped to the WSDL element name' do
        expect(hashes_to_convert).to match_array(
          [
            { name: 'CamelCase', args: [] },
            { name: 'With_Underscore', args: [] },
            { name: 'Oneword', args: [] }
          ]
        )
      end
    end

    context 'when the input hash is in a different order to the WSDL' do
      let(:elements) do
        {
          'First' => non_null_element('First'),
          'Second' => non_null_element('Second'),
          'Third' => non_null_element('Third')
        }
      end
      let(:hashes_to_convert) do
        [
          { name: 'third', args: [] },
          { name: 'first', args: [] },
          { name: 'second', args: [] }
        ]
      end

      it 'should order the request data following the WSDL' do
        expect(hashes_to_convert).to eq(
          [
            { name: 'First', args: [] },
            { name: 'Second', args: [] },
            { name: 'Third', args: [] }
          ]
        )
      end
    end

    context 'when the request data contains nil and is marked nullable' do
      let(:elements) do
        {
          'ShouldHaveNil' => null_element,
          'ShouldNotHaveNil' => non_null_element('ShouldNotHaveNil')
        }
      end
      let(:hashes_to_convert) do
        [
          { name: 'should_have_nil', args: [nil] },
          { name: 'should_not_have_nil', args: [] }
        ]
      end

      it 'should mark null types with a nil attribute' do
        expect(hashes_to_convert).to eq(
          [
            { name: 'ShouldHaveNil', args: [nil, { 'xsi:nil' => true }] },
            { name: 'ShouldNotHaveNil', args: [] }
          ]
        )
      end
    end
  end

  describe '::after_children_hash' do
    let(:input_hash) do
      {
        'FirstKey' => '',
        'Second' => '',
        'Thirdkey' => ''
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
      expect(keys).to match_array(%i[first_key second thirdkey])
    end
  end
end
