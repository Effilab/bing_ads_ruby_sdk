require "bing_ads_ruby_sdk/services/json/api_error"

RSpec.describe BingAdsRubySdk::Services::Json::ApiError do
  let(:category) { :PartialErrors }
  let(:error_payload) do
    [{ Index: 0, Code: "CampaignServiceSharedListIdInvalid", Message: "Error" }]
  end
  subject { described_class.new(category, error_payload) }

  describe "#details" do

    it "returns details" do
      expect(subject.details).to eq(error_payload)
    end
  end

  describe "#category" do
    it "returns category" do
      expect(subject.category).to eq(category)
    end
  end

  describe "#message" do
    it "returns formatted message" do
      expect(subject.message).to eq("PartialErrors: 0: CampaignServiceSharedListIdInvalid - Error")
    end

    context "when there are more than the limit of errors" do
      let(:error_payload) do
        [
          { Index: 0, Code: "TestCode", Message: "Error" },
          { Index: 1, Code: "TestCode", Message: "Error" },
          { Index: 2, Code: "TestCode", Message: "Error" }
        ]
      end
      let(:expected_message) do
        "PartialErrors: 0: TestCode - Error, 1: TestCode - Error (+1 not shown)"
      end

      it "returns formatted message with a note about other errors" do
        expect(subject.message).to eq(expected_message)
      end
    end
  end
end
