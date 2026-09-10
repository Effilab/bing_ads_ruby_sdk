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

  describe "#put" do
    before do
      allow(client).to receive(:put).and_return(response.to_json)
    end

    subject { service.put("operation", {message: "message"}) }

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

    describe "#get_shared_entities_by_account_id" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("SharedEntities/QueryByAccountId", payload)
        subject.get_shared_entities_by_account_id(payload)
      end
    end

    describe "#add_shared_entity" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("SharedEntity", payload)
        subject.add_shared_entity(payload)
      end
    end

    describe "#delete_shared_entities" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("SharedEntities", payload)
        subject.delete_shared_entities(payload)
      end
    end

    describe "#add_campaigns" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Campaigns", payload)
        subject.add_campaigns(payload)
      end
    end

    describe "#get_campaigns_by_account_id" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Campaigns/QueryByAccountId", payload)
        subject.get_campaigns_by_account_id(payload)
      end
    end

    describe "#get_campaigns_by_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Campaigns/QueryByIds", payload)
        subject.get_campaigns_by_ids(payload)
      end
    end

    describe "#add_campaign_criterions" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("CampaignCriterions", payload)
        subject.add_campaign_criterions(payload)
      end
    end

    describe "#delete_campaign_criterions" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("CampaignCriterions", payload)
        subject.delete_campaign_criterions(payload)
      end
    end

    describe "#add_budgets" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Budgets", payload)
        subject.add_budgets(payload)
      end
    end

    describe "#update_budgets" do
      it "calls put with the correct operation and payload" do
        expect(subject).to receive(:put).with("Budgets", payload)
        subject.update_budgets(payload)
      end
    end

    describe "#delete_budgets" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("Budgets", payload)
        subject.delete_budgets(payload)
      end
    end

    describe "#add_ad_groups" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("AdGroups", payload)
        subject.add_ad_groups(payload)
      end
    end

    describe "#update_ad_groups" do
      it "calls put with the correct operation and payload" do
        expect(subject).to receive(:put).with("AdGroups", payload)
        subject.update_ad_groups(payload)
      end
    end

    describe "#delete_ad_groups" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("AdGroups", payload)
        subject.delete_ad_groups(payload)
      end
    end

    describe "#add_ads" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Ads", payload)
        subject.add_ads(payload)
      end
    end

    describe "#add_responsive_search_ads" do
      it "builds a typed responsive search ad payload" do
        expect(subject).to receive(:post) do |operation, actual_payload|
          expect(operation).to eq("Ads")
          expect(actual_payload).to eq(
            ad_group_id: 123,
            ads: [{
              type: "ResponsiveSearch",
              status: "Paused",
              final_urls: ["https://www.example.com/"],
              headlines: [
                {asset: {type: "TextAsset", text: "Headline one"}},
                {asset: {type: "TextAsset", text: "Headline two"}},
                {asset: {type: "TextAsset", text: "Headline three"}}
              ],
              descriptions: [
                {asset: {type: "TextAsset", text: "Description one"}},
                {asset: {type: "TextAsset", text: "Description two"}}
              ],
              path1: "sdk",
              path2: "test"
            }]
          )
        end

        subject.add_responsive_search_ads(
          ad_group_id: 123,
          headlines: ["Headline one", "Headline two", "Headline three"],
          descriptions: ["Description one", "Description two"],
          final_urls: ["https://www.example.com/"],
          path1: "sdk",
          path2: "test"
        )
      end
    end

    describe "#update_ads" do
      it "calls put with the correct operation and payload" do
        expect(subject).to receive(:put).with("Ads", payload)
        subject.update_ads(payload)
      end
    end

    describe "#delete_ads" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("Ads", payload)
        subject.delete_ads(payload)
      end
    end

    describe "#add_keywords" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Keywords", payload)
        subject.add_keywords(payload)
      end
    end

    describe "#update_keywords" do
      it "calls put with the correct operation and payload" do
        expect(subject).to receive(:put).with("Keywords", payload)
        subject.update_keywords(payload)
      end
    end

    describe "#delete_keywords" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("Keywords", payload)
        subject.delete_keywords(payload)
      end
    end

    describe "#update_campaigns" do
      it "calls put with the correct operation and payload" do
        expect(subject).to receive(:put).with("Campaigns", payload)
        subject.update_campaigns(payload)
      end
    end

    describe "#delete_campaigns" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("Campaigns", payload)
        subject.delete_campaigns(payload)
      end
    end

    describe "#set_shared_entity_associations" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("SharedEntityAssociations/Set", payload)
        subject.set_shared_entity_associations(payload)
      end
    end

    describe "#get_shared_entity_associations_by_entity_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("SharedEntityAssociations/QueryByEntityIds", payload)
        subject.get_shared_entity_associations_by_entity_ids(payload)
      end
    end

    describe "#add_ad_extensions" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("AdExtensions", payload)
        subject.add_ad_extensions(payload)
      end
    end

    describe "#get_ad_extension_ids_by_account_id" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("AdExtensionIds/QueryByAccountId", payload)
        subject.get_ad_extension_ids_by_account_id(payload)
      end
    end

    describe "#get_ad_extensions_by_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("AdExtensions/QueryByIds", payload)
        subject.get_ad_extensions_by_ids(payload)
      end
    end

    describe "#get_ad_extensions_associations" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("AdExtensionsAssociations/Query", payload)
        subject.get_ad_extensions_associations(payload)
      end
    end

    describe "#set_ad_extensions_associations" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("AdExtensionsAssociations/Set", payload)
        subject.set_ad_extensions_associations(payload)
      end
    end

    describe "#delete_ad_extensions_associations" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("AdExtensionsAssociations", payload)
        subject.delete_ad_extensions_associations(payload)
      end
    end

    describe "#delete_ad_extensions" do
      it "calls delete with the correct operation and payload" do
        expect(subject).to receive(:delete).with("AdExtensions", payload)
        subject.delete_ad_extensions(payload)
      end
    end

    describe "#add_conversion_goals" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("ConversionGoals", payload)
        subject.add_conversion_goals(payload)
      end
    end

    describe "#get_conversion_goals_by_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("ConversionGoals/QueryByIds", payload)
        subject.get_conversion_goals_by_ids(payload)
      end
    end

    describe "#get_conversion_goals_by_tag_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("ConversionGoals/QueryByTagIds", payload)
        subject.get_conversion_goals_by_tag_ids(payload)
      end
    end

    describe "#update_conversion_goals" do
      it "calls put with the correct operation and payload" do
        expect(subject).to receive(:put).with("ConversionGoals", payload)
        subject.update_conversion_goals(payload)
      end
    end

    describe "#add_uet_tags" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("UetTags", payload)
        subject.add_uet_tags(payload)
      end
    end

    describe "#get_uet_tags_by_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("UetTags/QueryByIds", payload)
        subject.get_uet_tags_by_ids(payload)
      end
    end

    describe "#update_uet_tags" do
      it "calls put with the correct operation and payload" do
        expect(subject).to receive(:put).with("UetTags", payload)
        subject.update_uet_tags(payload)
      end
    end

    describe "#get_ad_groups_by_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("AdGroups/QueryByIds", payload)
        subject.get_ad_groups_by_ids(payload)
      end
    end

    describe "#get_ad_groups_by_campaign_id" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("AdGroups/QueryByCampaignId", payload)
        subject.get_ad_groups_by_campaign_id(payload)
      end
    end

    describe "#get_ads_by_ad_group_id" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Ads/QueryByAdGroupId", payload)
        subject.get_ads_by_ad_group_id(payload)
      end
    end

    describe "#get_budgets_by_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Budgets/QueryByIds", payload)
        subject.get_budgets_by_ids(payload)
      end
    end

    describe "#get_campaign_criterions_by_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("CampaignCriterions/QueryByIds", payload)
        subject.get_campaign_criterions_by_ids(payload)
      end
    end

    describe "#get_keywords_by_ad_group_id" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Keywords/QueryByAdGroupId", payload)
        subject.get_keywords_by_ad_group_id(payload)
      end
    end

    describe "#get_keywords_by_editorial_status" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Keywords/QueryByEditorialStatus", payload)
        subject.get_keywords_by_editorial_status(payload)
      end
    end

    describe "#get_keywords_by_ids" do
      it "calls post with the correct operation and payload" do
        expect(subject).to receive(:post).with("Keywords/QueryByIds", payload)
        subject.get_keywords_by_ids(payload)
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
