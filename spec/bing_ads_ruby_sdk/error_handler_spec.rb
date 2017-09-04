require 'spec_helper'

RSpec.describe BingAdsRubySdk::Errors::ErrorHandler do
  describe '::parse_errors' do
    let(:standard_error) { BingAdsRubySdk::Errors::StandardError }
    subject(:call_method) { described_class.parse_errors!(api_response) }

    context 'when there is no fault' do
      let(:api_response) do
        {
          is_migrated: 'false',
          nested_partial_errors: ''
        }
      end

      it { is_expected.to eq nil }
    end

    context 'when there is a fault' do
      let(:api_response) do
        {
          faultcode: "s:Server",
          faultstring: "Invalid client data. Check the SOAP fault details for more information",
          detail: detail
        }
      end

      let(:batch_error) do
        {
          code: '0000',
          details: 'Batch error details',
          error_code: 'UserIsNotAuthorized',
          field_path: '{lpurl}',
          index: '0',
          message: 'Batch error message',
          type: 'reserved for internal use'
        }
      end
      let(:batch_error_list) { [batch_error] }

      let(:editorial_error_list) do
        [
          # Inherits from BatchError
          batch_error.merge(
            {
              appealable: true,
              disapproved_text: 'The text that caused the entity to be disapproved',
              location: 'ElementName',
              publisher_country: 'New Zealand',
              reason_code: 4
            }
          )
        ]
      end

      let(:operation_error_list_as_hash) do
        {
          operation_error: {
            code: "4503",
            details: "Invalid API Campaign Criterion Type : 0 on API tier",
            error_code: "CampaignCriterionTypeInvalid",
            message: "The campaign criterion's type is not valid."
          }
        }
      end

      let(:error_message) do
        'Bing Ads API error. See exception details for more information.'
      end

      shared_examples 'raises an error' do
        example do
          expect { call_method }.to raise_error do |error|
            expect(error).to be_a(error_class)
            expect(error).to have_attributes(error_attributes)
            expect(error.message).to eq error_message
          end
        end
      end

      context 'of type ApiFaultDetail' do
        let(:detail) do
          {
            api_fault_detail: {
              tracking_id: '14f89175-e806-4822-8aa7-32b0c7734e11',
              batch_errors: '',
              operation_errors: operation_error_list_as_hash
            }
          }
        end

        let(:error_attributes) do
          {
            batch_errors: '',
            operation_errors: operation_error_list_as_hash
          }
        end
        
        let(:error_class) { BingAdsRubySdk::Errors::ApiFaultDetail }

        it_behaves_like 'raises an error'
      end

      context 'of type AdApiFaultDetail' do
        let(:detail) do
          {
            ad_api_fault_detail: {
              tracking_id: '14f89175-e806-4822-8aa7-32b0c7734e11',
              errors: errors
            }
          }
        end

        let(:errors) do
          {
            code: '0000',
            detail: 'Details about error',
            error_code: 'UserIsNotAuthorized',
            message: 'Fault message'
          }
        end

        let(:error_class) { BingAdsRubySdk::Errors::AdApiFaultDetail }
        let(:error_attributes) { { errors: errors } }

        it_behaves_like 'raises an error'
      end

      context 'of type EditorialApiFaultDetail' do
        let(:detail) do
          {
            editorial_api_fault_detail: {
              tracking_id: '14f89175-e806-4822-8aa7-32b0c7734e11',
              batch_errors: batch_error_list,
              editorial_errors: editorial_error_list,
              operation_errors: operation_error_list_as_hash
            }
          }
        end

        let(:error_class) { BingAdsRubySdk::Errors::EditorialApiFaultDetail }

        let(:error_attributes) do
          {
            batch_errors: batch_error_list,
            editorial_errors: editorial_error_list,
            operation_errors: operation_error_list_as_hash
          }
        end

        it_behaves_like 'raises an error'
      end

      context 'of type ApiBatchFault' do
        let(:detail) do
          {
            api_batch_fault: {
              tracking_id: '14f89175-e806-4822-8aa7-32b0c7734e11',
              batch_errors: batch_error_list
            }
          }
        end

        let(:error_class) { BingAdsRubySdk::Errors::ApiBatchFault }
        let(:error_attributes) { { batch_errors: batch_error_list } }

        it_behaves_like 'raises an error'
      end

      context 'of type ApiFault' do
        let(:detail) do
          {
            api_fault: {
              tracking_id: '14f89175-e806-4822-8aa7-32b0c7734e11',
              operation_errors: operation_error_list_as_hash
            }
          }
        end

        let(:error_attributes) { { operation_errors: operation_error_list_as_hash } }
        let(:error_class) { BingAdsRubySdk::Errors::ApiFault }

        it_behaves_like 'raises an error'
      end

      context 'of type InvalidCredentials' do
        let(:api_response) do
          {
            code: "105",
            detail: nil,
            error_code: "InvalidCredentials",
            message: "Authentication failed. Either supplied credentials are invalid or the account is inactive"
          }
        end

        let(:error_class) { standard_error }

        let(:error_attributes) { { raw_response: api_response } }

        let(:error_message) do
          "Bing Ads API error. #{ api_response[:message] }"
        end

        it_behaves_like 'raises an error'
      end

      context 'of an unknown type' do
        let(:detail) do
          {
            new_fault_unknown_to_sdk: {
              tracking_id: '14f89175-e806-4822-8aa7-32b0c7734e11',
              new_field: 'value'
            }
          }
        end

        let(:error_class) { standard_error }

        let(:error_attributes) { { raw_response: api_response } }

        it_behaves_like 'raises an error'
      end

      context 'when there are no details' do
        let(:detail) { nil }
        let(:error_class) { standard_error }
        let(:error_attributes) { { raw_response: api_response } }

        it_behaves_like 'raises an error'
      end
    end
  end
end