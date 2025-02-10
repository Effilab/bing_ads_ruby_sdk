require "bing_ads_ruby_sdk/services/json/campaign_management"

RSpec.describe BingAdsRubySdk::Services::Json::CampaignManagement do
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
  let(:error_message) { "Error, Error (+4 not shown)" }
  let(:client) { BingAdsRubySdk::HttpClient }
  let(:auth_handler) { double(:auth_handler, fetch_or_refresh: "token") }

  def service
    described_class.new(base_url: "http://example.com", headers: {}, auth_handler: auth_handler)
  end

  shared_examples "handling responses" do
    let(:error_class) { BingAdsRubySdk::Services::Json::ApiError }

    context "when the response has no errors" do
      let(:response) { {foo: "bar"} }

      it "returns the response" do
        expect(subject).to eq(response)
      end
    end

    context "when the response has a Batch error" do
      let(:response) { {BatchErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(error_class, error_message)
      end
    end

    context "when the response has an Operation error" do
      let(:response) { {OperationErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(error_class, error_message)
      end
    end

    context "when the response has a Partial error" do
      let(:response) { {PartialErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(error_class, error_message)
      end
    end
  end

  describe "#post" do
    before do
      allow(client).to receive(:post).and_return(response.to_json)
    end

    subject { service.post("operation", {message: "message"}) }

    include_examples "handling responses"
  end

  describe "#delete" do
    before do
      allow(client).to receive(:delete).and_return(response.to_json)
    end

    subject { service.delete("operation", {message: "message"}) }

    include_examples "handling responses"
  end

  describe "Helper methods" do
    subject { service }
    let(:message) { {fake_element: :fake_value} }

    describe "#get_shared_entities" do
      it "calls post with the correct operation and message" do
        expect(subject).to receive(:post).with("SharedEntities/Query", message)
        subject.get_shared_entities(message)
      end
    end

    describe "#add_shared_entity" do
      it "calls post with the correct operation and message" do
        expect(subject).to receive(:post).with("SharedEntity", message)
        subject.add_shared_entity(message)
      end
    end

    describe "#get_list_items_by_shared_list" do
      it "calls post with the correct operation and message" do
        expect(subject).to receive(:post).with("ListItems/QueryBySharedList", message)
        subject.get_list_items_by_shared_list(message)
      end
    end

    describe "#add_list_items_to_shared_list" do
      it "calls post with the correct operation and message" do
        expect(subject).to receive(:post).with("ListItems", message)
        subject.add_list_items_to_shared_list(message)
      end
    end

    describe "#delete_list_items_from_shared_list" do
      it "calls delete with the correct operation and message" do
        expect(subject).to receive(:delete).with("ListItems", message)
        subject.delete_list_items_from_shared_list(message)
      end
    end
  end
end
