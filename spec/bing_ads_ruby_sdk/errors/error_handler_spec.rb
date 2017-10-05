# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BingAdsRubySdk::Errors::ErrorHandler do
  describe '::parse_errors' do
    let(:general_error) { BingAdsRubySdk::Errors::GeneralError }
    subject(:call_method) { described_class.parse_errors!(api_response) }

    shared_examples 'raises an error' do
      example do
        expect { call_method }.to raise_error do |error|
          expect(error).to be_a(error_class)
          expect(error).to have_attributes(error_attributes)
        end
      end
    end

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
          faultcode: 's:Server',
          faultstring:
            'Invalid client data. Check the SOAP fault details',
          detail: detail
        }
      end

      let(:batch_error) do
        {
          batch_error: {
            code: '0000',
            details: 'Batch error details',
            error_code: 'ErrorCode',
            field_path: '{lpurl}',
            index: '0',
            message: 'Batch error message',
            type: 'reserved for internal use'
          }
        }
      end
      let(:batch_error_list) { [batch_error] }

      let(:editorial_error_list) do
        [
          # Inherits from BatchError
          batch_error[:batch_error].merge(
            appealable: true,
            disapproved_text: 'The text that caused the entity to ...',
            location: 'ElementName',
            publisher_country: 'New Zealand',
            reason_code: 4
          )
        ]
      end

      let(:operation_error_list_as_hash) do
        {
          operation_error: {
            code: '4503',
            details: 'Invalid API Campaign Criterion Type : 0 on API tier',
            error_code: 'TypeInvalid',
            message: "The campaign criterion ..."
          }
        }
      end

      let(:error_message) do
        'Bing Ads API error - Invalid client data. Check the SOAP fault details'
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
            operation_errors: operation_error_list_as_hash,
            message: "TypeInvalid - The campaign criterion ..."
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
            ad_api_error: {
              code: '0000',
              detail: 'Details about error',
              error_code: 'ErrorCode',
              message: 'Fault message'
            }
          }
        end

        let(:error_class) { BingAdsRubySdk::Errors::AdApiFaultDetail }
        let(:error_attributes) do
          {
            errors: errors,
            message: 'ErrorCode - Fault message'
          }
        end

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
            operation_errors: operation_error_list_as_hash,
            message: error_message
          }
        end

        context 'when all the lists have errors' do
          let(:error_message) do
            'API raised 3 errors, including: ErrorCode - Batch error message'
          end
          it_behaves_like 'raises an error'
        end

        context 'when some of the lists are empty' do
          let(:batch_error_list) { [] }
          let(:editorial_error_list) { [] }
          let(:error_message) do
            "TypeInvalid - The campaign criterion ..."
          end

          it_behaves_like 'raises an error'
        end
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
        let(:error_attributes) do
          {
            batch_errors: batch_error_list,
            message: 'ErrorCode - Batch error message'
          }
        end

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

        let(:error_attributes) do
          {
            operation_errors: operation_error_list_as_hash,
            message: "TypeInvalid - The campaign criterion ..."
          }
        end
        let(:error_class) { BingAdsRubySdk::Errors::ApiFault }

        it_behaves_like 'raises an error'
      end

      context 'of type InvalidCredentials' do
        let(:api_response) do
          {
            code: '105',
            detail: nil,
            error_code: 'InvalidCredentials',
            message: 'Authentication failed. Either supplied ...'
          }
        end

        let(:error_class) { general_error }

        let(:error_attributes) do
          {
            raw_response: api_response,
            message: "InvalidCredentials - #{api_response[:message]}"
          }
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

        let(:error_class) { general_error }

        let(:error_attributes) do
          {
            raw_response: api_response,
            message: error_message
          }
        end

        it_behaves_like 'raises an error'
      end

      context 'when there are no details' do
        let(:detail) { nil }
        let(:error_class) { general_error }
        let(:error_attributes) do
          {
            raw_response: api_response,
            message: error_message
          }
        end

        it_behaves_like 'raises an error'
      end

      context 'when there is no error_code' do
        let(:detail) do
          {
            api_fault: {
              tracking_id: '14f89175-e806-4822-8aa7-32b0c7734e11',
              batch_errors: '',
              operation_errors: {
                operation_error: {
                  code: '1001',
                  details: '',
                  message: 'The user is not authorized to perform this action.'
                }
              }
            }
          }
        end
        let(:error_class) { BingAdsRubySdk::Errors::ApiFault }
        let(:error_attributes) do
          {
            raw_response: api_response,
            message: 'The user is not authorized to perform this action.'
          }
        end

        it_behaves_like 'raises an error'
      end
    end

    context 'when there is a deserialization error' do
      # rubocop:disable Metrics/LineLength
      let(:api_response) do
        {
          faultcode: 'a:DeserializationFailed',
          faultstring: "The formatter threw an exception while trying to deserialize the message: There was an error while trying to deserialize parameter https://bingads.microsoft.com/CampaignManagement/v11:CampaignId. The InnerException message was 'There was an error deserializing the object of type System.Int64. The value '' cannot be parsed as the type 'Int64'.'.  Please see InnerException for more details.",
          detail: {
            exception_detail: {
              help_link: nil,
              inner_exception: {
                help_link: nil,
                inner_exception: {
                  help_link: nil,
                  inner_exception: {
                    help_link: nil,
                    inner_exception: nil,
                    message: 'Input string was not in a correct format.',
                    stack_trace: "   at System.Number.StringToNumber(String str, NumberStyles options, NumberBuffer& number, NumberFormatInfo info, Boolean parseDecimal)\r\n   at System.Number.ParseInt64(String value, NumberStyles options, NumberFormatInfo numfmt)\r\n   at System.Xml.XmlConverter.ToInt64(String value)",
                    type: 'System.FormatException'
                  },
                  message: "The value '' cannot be parsed as the type 'Int64'.",
                  stack_trace: "   at System.Xml.XmlConverter.ToInt64(String value)\r\n   at System.Xml.XmlDictionaryReader.ReadElementContentAsLong()\r\n   at System.Runtime.Serialization.LongDataContract.ReadXmlValue(XmlReaderDelegator reader, XmlObjectSerializerReadContext context)\r\n   at System.Runtime.Serialization.XmlObjectSerializer.ReadObjectHandleExceptions(XmlReaderDelegator reader, Boolean verifyObjectName, DataContractResolver dataContractResolver)",
                  type: 'System.Xml.XmlException'
                },
                message: "There was an error deserializing the object of type System.Int64. The value '' cannot be parsed as the type 'Int64'.",
                stack_trace: "   at System.Runtime.Serialization.XmlObjectSerializer.ReadObjectHandleExceptions(XmlReaderDelegator reader, Boolean verifyObjectName, DataContractResolver dataContractResolver)\r\n   at System.Runtime.Serialization.DataContractSerializer.ReadObject(XmlDictionaryReader reader, Boolean verifyObjectName)\r\n   at System.ServiceModel.Dispatcher.DataContractSerializerOperationFormatter.PartInfo.ReadObject(XmlDictionaryReader reader, XmlObjectSerializer serializer)\r\n   at System.ServiceModel.Dispatcher.DataContractSerializerOperationFormatter.DeserializeParameterPart(XmlDictionaryReader reader, PartInfo part, Boolean isRequest)",
                type: 'System.Runtime.Serialization.SerializationException'
              },
              message: "The formatter threw an exception while trying to deserialize the message: There was an error while trying to deserialize parameter https://bingads.microsoft.com/CampaignManagement/v11:CampaignId. The InnerException message was 'There was an error deserializing the object of type System.Int64. The value '' cannot be parsed as the type 'Int64'.'.  Please see InnerException for more details.",
              stack_trace: "   at System.ServiceModel.Dispatcher.DataContractSerializerOperationFormatter.DeserializeParameterPart(XmlDictionaryReader reader, PartInfo part, Boolean isRequest)\r\n   at System.ServiceModel.Dispatcher.DataContractSerializerOperationFormatter.DeserializeParameters(XmlDictionaryReader reader, PartInfo[] parts, Object[] parameters, Boolean isRequest)\r\n   at System.ServiceModel.Dispatcher.DataContractSerializerOperationFormatter.DeserializeBody(XmlDictionaryReader reader, MessageVersion version, String action, MessageDescription messageDescription, Object[] parameters, Boolean isRequest)\r\n   at System.ServiceModel.Dispatcher.OperationFormatter.DeserializeBodyContents(Message message, Object[] parameters, Boolean isRequest)\r\n   at System.ServiceModel.Dispatcher.OperationFormatter.DeserializeRequest(Message message, Object[] parameters)\r\n   at System.ServiceModel.Dispatcher.DispatchOperationRuntime.DeserializeInputs(MessageRpc& rpc)\r\n   at System.ServiceModel.Dispatcher.DispatchOperationRuntime.InvokeBegin(MessageRpc& rpc)\r\n   at System.ServiceModel.Dispatcher.ImmutableDispatchRuntime.ProcessMessage5(MessageRpc& rpc)\r\n   at System.ServiceModel.Dispatcher.ImmutableDispatchRuntime.ProcessMessage11(MessageRpc& rpc)\r\n   at System.ServiceModel.Dispatcher.MessageRpc.Process(Boolean isOperationContextSet)",
              type: 'System.ServiceModel.Dispatcher.NetDispatcherFaultException'
            }
          }
        }
      end
      # rubocop:enable Metrics/LineLength

      let(:error_class) { BingAdsRubySdk::Errors::GeneralError }
      let(:error_attributes) do
        {
          raw_response: api_response,
          message: "Bing Ads API error - The formatter threw an exception while trying to deserialize the message: There was an error while trying to deserialize parameter https://bingads.microsoft.com/CampaignManagement/v11:CampaignId. The InnerException message was 'There was an error deserializing the object of type System.Int64. The value '' cannot be parsed as the type 'Int64'.'.  Please see InnerException for more details."
        }
      end

      it_behaves_like 'raises an error'
    end

    context 'when there are nested partial errors' do
      let(:api_response) do
        {
          campaign_criterion_ids: [],
          is_migrated: 'false',
          nested_partial_errors: {
            batch_error_collection: [
              {
                batch_errors: nil,
                code: '1043',
                details: 'Criterion already exists',
                error_code: 'AlreadyExists',
                field_path: nil,
                forward_compatibility_map: nil,
                index: '0',
                message: 'The specified entity already exists.',
                type: 'BatchErrorCollection'
              }
            ]
          }
        }
      end

      context 'when the default behaviour is used' do
        let(:error_class) { BingAdsRubySdk::Errors::NestedPartialError }
        let(:error_attributes) do
          {
            raw_response: api_response,
            message: 'AlreadyExists - The specified entity already exists.'
          }
        end

        it_behaves_like 'raises an error'
      end

      context 'when the ignore partial errors switch is on' do
        it 'should return the NestedPartialError as a Hash'
      end
    end

    context 'when there are partial errors' do
      let(:api_response) do
        {
          campaign_ids: [],
          partial_errors: {
            batch_error: [
              {
                code: '4701',
                details: nil,
                error_code: 'UnsupportedBiddingScheme',
                field_path: nil,
                forward_compatibility_map: nil,
                index: '0',
                message: 'The bidding...',
                type: 'BatchError'
              },
              {
                code: '4701',
                details: nil,
                error_code: 'UnsupportedBiddingScheme',
                field_path: nil,
                forward_compatibility_map: nil,
                index: '1',
                message: 'The bidding...',
                type: 'BatchError'
              }
            ]
          }
        }
      end

      context 'when the default behaviour is used' do
        let(:error_class) { BingAdsRubySdk::Errors::PartialError }

        let(:error_attributes) do
          {
            raw_response: api_response,
            message: 'API raised 2 errors, including: UnsupportedBiddingScheme - The bidding...'
          }
        end

        it_behaves_like 'raises an error'
      end

      context 'when the ignore partial errors switch is on' do
        it 'should return the PartialError as a Hash'
      end
    end
  end
end
