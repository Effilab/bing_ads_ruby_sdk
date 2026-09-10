# frozen_string_literal: true

RSpec.describe "JSON Shared Entities API" do
  include_context "json api with vcr"

  it "creates a negative keyword list" do
    use_json_api_cassette("shared_entities_creates_negative_keyword_list") do
      with_shared_list do |shared_entity_id, response|
        expect(response[:SharedEntityId]).to eq(shared_entity_id)
      end
    end
  end

  it "reads a negative keyword list" do
    use_json_api_cassette("shared_entities_reads_negative_keyword_list") do
      with_shared_list do |shared_entity_id|
        response = api.campaign_management.get_shared_entities(
          shared_entity_type: "NegativeKeywordList",
          shared_entity_scope: "Account"
        )

        expect(response[:SharedEntities].map { |entity| entity[:Id] }).to include(shared_entity_id)
      end
    end
  end

  it "reads list items" do
    use_json_api_cassette("shared_entities_reads_list_items") do
      with_shared_list do |shared_entity_id|
        response = api.campaign_management.get_list_items_by_shared_list(
          shared_list: {id: shared_entity_id, type: "NegativeKeywordList"},
          shared_entity_scope: "Account"
        )

        expect(response[:ListItems]).not_to be_empty
      end
    end
  end

  it "adds and removes a list item" do
    use_json_api_cassette("shared_entities_adds_and_removes_list_item") do
      with_shared_list do |shared_entity_id|
        shared_list = {id: shared_entity_id, type: "NegativeKeywordList"}
        added = api.campaign_management.add_list_items_to_shared_list(
          list_items: [{type: "NegativeKeyword", text: "sdk-vcr-second-keyword", match_type: "Exact"}],
          shared_list: shared_list,
          shared_entity_scope: "Account"
        )
        list_item_id = added.fetch(:ListItemIds).first

        response = api.campaign_management.delete_list_items_from_shared_list(
          list_item_ids: [list_item_id],
          shared_list: shared_list,
          shared_entity_scope: "Account"
        )

        expect(response).to include(:PartialErrors)
        expect(response[:PartialErrors]).to be_nil
      end
    end
  end

  it "deletes a negative keyword list" do
    use_json_api_cassette("shared_entities_deletes_negative_keyword_list") do
      with_shared_list do |shared_entity_id|
        response = api.campaign_management.delete_shared_entities(
          shared_entities: [{id: shared_entity_id, type: "NegativeKeywordList"}],
          shared_entity_scope: "Account"
        )

        expect(response[:PartialErrors]).to eq([])
        @shared_entity_deleted = true
      end
    end
  end
end
