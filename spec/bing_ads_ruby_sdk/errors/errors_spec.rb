# frozen_string_literal: true

RSpec.describe BingAdsRubySdk::Errors::ApplicationFault do
  describe "#fault_hash" do
    context "when creating an instance" do
      subject(:create_instance) { described_class.new({details: nil}) }

      it "instantiates without raising an exception" do
        expect { create_instance }.not_to raise_error
      end
    end
  end
end

# Per learn.microsoft.com/en-us/advertising/campaign-management-service, JSON API
# responses only ever expose `PartialErrors` (BatchError[]) and, for some
# operations, `NestedPartialErrors` (BatchError[][]) at the response root ---
# never `BatchErrors`/`OperationErrors`, which are SOAP-only `detail` fields.
RSpec.describe BingAdsRubySdk::Errors::PartialError do
  let(:error) { {error_code: "CampaignServiceSharedListIdInvalid", message: "Error"} }

  subject(:fault) { described_class.new(response) }

  context "when given a JSON API response" do
    let(:response) { {partial_errors: [error, error]} }

    it "populates batch_error from the flat array" do
      expect(fault.batch_error).to eq([error, error])
    end

    it "deduplicates identical error messages" do
      expect(fault.message).to eq("CampaignServiceSharedListIdInvalid - Error")
    end
  end
end

RSpec.describe BingAdsRubySdk::Errors::NestedPartialError do
  let(:error) { {error_code: "CampaignServiceSharedListIdInvalid", message: "Error"} }
  let(:other_error) { {error_code: "OtherCode", message: "Other error"} }

  subject(:fault) { described_class.new(response) }

  context "when given a JSON API response" do
    let(:response) { {nested_partial_errors: [[error, error], [other_error]]} }

    it "populates batch_error_collection from the array of arrays" do
      expect(fault.batch_error_collection).to eq([[error, error], [other_error]])
    end

    it "flattens nested lists and deduplicates identical error messages" do
      expect(fault.message).to eq("CampaignServiceSharedListIdInvalid - Error, OtherCode - Other error")
    end
  end
end
