require "bing_ads_ruby_sdk/services/json/campaign_management"

RSpec.describe BingAdsRubySdk::Services::Json::CampaignManagement do
  let(:client) { BingAdsRubySdk::HttpClient }
  let(:auth_handler) { double(:auth_handler, fetch_or_refresh: "token") }

  def service
    described_class.new(base_url: "http://example.com", headers: {}, auth_handler: auth_handler)
  end

  shared_examples "handling responses" do
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
    let(:error_class) { BingAdsRubySdk::Services::Json::ApiError }
    let(:error_message) { "0: 4317 - Error, 0: 4317 - Error (+4 not shown)" }

    context "when the response has no errors" do
      let(:response) { {foo: "bar"} }

      it "returns the response" do
        expect(subject).to eq(response)
      end
    end

    context "when the response has a Batch error" do
      let(:response) { {BatchErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(error_class, "BatchErrors: #{error_message}")
      end
    end

    context "when the response has an Operation error" do
      let(:response) { {OperationErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(error_class, "OperationErrors: #{error_message}")
      end
    end

    context "when the response has a Partial error" do
      let(:response) { {PartialErrors: error_list} }

      it "raises an error" do
        expect { subject }.to raise_error(error_class, "PartialErrors: #{error_message}")
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
    let(:payload) { {fake_element: :fake_value} }

    describe "#get_shared_entities" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("SharedEntities/Query", payload)
        subject.get_shared_entities(payload)
      end
    end

    describe "#add_shared_entity" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("SharedEntity", payload)
        subject.add_shared_entity(payload)
      end
    end

    describe "#get_list_items_by_shared_list" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("ListItems/QueryBySharedList", payload)
        subject.get_list_items_by_shared_list(payload)
      end
    end

    describe "#add_list_items_to_shared_list" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("ListItems", payload)
        subject.add_list_items_to_shared_list(payload)
      end
    end

    describe "#delete_list_items_from_shared_list" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("ListItems", payload)
        subject.delete_list_items_from_shared_list(payload)
      end
    end
  end
end
