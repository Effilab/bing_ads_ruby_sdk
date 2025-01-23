RSpec.describe BingAdsRubySdk::Services::Json do
  let(:error) do
    {
      FieldPath: nil,
      ErrorCode: "CampaignServiceSharedListIdInvalid",
      Message: "Error",
      Code: 4317,
      Details: nil,
      Index: 0,
      Type: "BatchError",
      ForwardCompatibilityMap: nil
    }
  end
  let(:error_list) { Array.new(6, error) }
  # Only the first 5 errors are shown in the error message
  let(:error_message) { "Error, Error, Error, Error, Error ..." }
  let(:client) { BingAdsRubySdk::HttpClient }
  let(:auth_handler) { double(:auth_handler, fetch_or_refresh: "token") }

  def json_instance
    described_class.new(base_url: "http://example.com", headers: {}, auth_handler: auth_handler)
  end

  shared_examples "handling responses" do
    context "when the response has no errors" do
      let(:response) { {foo: "bar"} }

      it "returns the response" do
        expect(subject).to eq(response)
      end
    end

    context "when the response has a Batch error" do
      let(:response) { {BatchErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(BingAdsRubySdk::Services::Json::ApiError, error_message)
      end
    end

    context "when the response has an Operation error" do
      let(:response) { {OperationErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(BingAdsRubySdk::Services::Json::ApiError, error_message)
      end
    end

    context "when the response has a Partial error" do
      let(:response) { {PartialErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(BingAdsRubySdk::Services::Json::ApiError, error_message)
      end
    end
  end

  describe "#post" do
    before do
      allow(client).to receive(:post).and_return(response.to_json)
    end

    subject { json_instance.post("operation", {message: "message"}) }

    include_examples "handling responses"
  end

  describe "#delete" do
    before do
      allow(client).to receive(:delete).and_return(response.to_json)
    end

    subject { json_instance.delete("operation", {message: "message"}) }

    include_examples "handling responses"
  end
end
