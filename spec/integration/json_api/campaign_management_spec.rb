# frozen_string_literal: true

RSpec.describe "JSON Campaign Management API" do
  include_context "json api with vcr"

  it "queries campaigns through Campaign Management" do
    use_json_api_cassette("queries_campaigns_through_Campaign_Management") do
      with_paused_campaign do
        response = api.campaign_management.get_campaigns_by_account_id(
          account_id: account_id,
          fields: ["Id", "Name", "Status"]
        )

        expect(response[:campaigns]).not_to be_empty
      end
    end
  end

  it "queries a seeded campaign by ID" do
    use_json_api_cassette("queries_a_seeded_campaign_by_ID") do
      with_paused_campaign do |campaign_id|
        response = api.campaign_management.get_campaigns_by_ids(
          account_id: account_id,
          campaign_ids: [campaign_id],
          fields: ["Id", "Name", "Status"]
        )

        expect(response[:campaigns].first[:id]).to eq(campaign_id)
      end
    end
  end

  it "queries a seeded campaign by ID through the dedicated endpoint" do
    use_json_api_cassette("campaign_management_get_campaigns_by_ids") do
      with_paused_campaign do |campaign_id|
        response = api.campaign_management.get_campaigns_by_ids(
          account_id: account_id,
          campaign_ids: [campaign_id],
          fields: ["Id", "Name", "Status"]
        )

        expect(response[:campaigns].first[:id]).to eq(campaign_id)
      end
    end
  end

  it "creates a paused campaign" do
    use_json_api_cassette("campaign_management_add_campaigns") do
      with_campaign do |campaign_id, response|
        expect(response[:campaign_ids]).to include(campaign_id)
      end
    end
  end

  it "updates a paused campaign" do
    use_json_api_cassette("campaign_management_update_campaigns") do
      with_campaign do |campaign_id|
        response = api.campaign_management.update_campaigns(
          account_id: account_id,
          campaigns: [{
            id: campaign_id,
            name: "SDK VCR Campaign Updated",
            daily_budget: 2,
            budget_type: "DailyBudgetStandard",
            time_zone: "BrusselsCopenhagenMadridParis",
            status: "Paused"
          }]
        )

        expect(response[:partial_errors]).to eq([])
        updated = api.campaign_management.get_campaigns_by_ids(
          account_id: account_id,
          campaign_ids: [campaign_id],
          fields: ["Id", "Name", "Status"]
        )
        expect(updated[:campaigns].first[:name]).to eq("SDK VCR Campaign Updated")
      end
    end
  end

  it "deletes a paused campaign" do
    use_json_api_cassette("campaign_management_delete_campaigns") do
      with_campaign do |campaign_id, _response, campaign_name|
        response = api.campaign_management.delete_campaigns(
          account_id: account_id,
          campaign_ids: [campaign_id]
        )

        expect(response[:partial_errors]).to eq([])
        @campaign_deleted = true
        remaining = api.campaign_management.get_campaigns_by_account_id(
          account_id: account_id,
          fields: ["Id", "Name"]
        )
        expect(remaining[:campaigns].none? { |campaign| campaign[:name] == campaign_name }).to be(true)
      end
    end
  end

  it "associates and removes a placement exclusion list" do
    use_json_api_cassette("campaign_management_associate_and_remove_placement_exclusion_list") do
      lists = api.campaign_management.get_shared_entities(
        shared_entity_scope: "Customer",
        shared_entity_type: "PlacementExclusionList"
      ).fetch(:shared_entities)
      list = lists.find { |entity| entity[:name] == "BSA Managed 1" }
      list_id = list.fetch(:id)
      association = {
        entity_id: account_id,
        entity_type: "Account",
        shared_entity_id: list_id,
        shared_entity_type: "PlacementExclusionList"
      }
      existing = api.campaign_management.get_shared_entity_associations_by_entity_ids(
        entity_ids: [account_id],
        entity_type: "Account",
        shared_entity_type: "PlacementExclusionList",
        shared_entity_scope: "Customer"
      ).fetch(:associations)

      expect(existing).not_to include(
        hash_including(shared_entity_id: list_id.to_s)
      )

      begin
        response = api.campaign_management.set_shared_entity_associations(
          shared_entity_scope: "Customer",
          associations: [association]
        )
        expect(response[:partial_errors]).to eq([])

        associated = api.campaign_management.get_shared_entity_associations_by_entity_ids(
          entity_ids: [account_id],
          entity_type: "Account",
          shared_entity_type: "PlacementExclusionList",
          shared_entity_scope: "Customer"
        ).fetch(:associations)
        expect(associated).to include(
          hash_including(
            entity_id: account_id.to_s,
            shared_entity_id: list_id.to_s,
            shared_entity_type: "PlacementExclusionList"
          )
        )
      ensure
        response = api.campaign_management.delete(
          "SharedEntityAssociations",
          shared_entity_scope: "Customer",
          associations: [association]
        )
        expect(response[:partial_errors]).to eq([])
      end

      remaining = api.campaign_management.get_shared_entity_associations_by_entity_ids(
        entity_ids: [account_id],
        entity_type: "Account",
        shared_entity_type: "PlacementExclusionList",
        shared_entity_scope: "Customer"
      ).fetch(:associations)
      expect(remaining).not_to include(
        hash_including(shared_entity_id: list_id.to_s)
      )
    end
  end

  it "queries a seeded ad group by campaign" do
    use_json_api_cassette("queries_a_seeded_ad_group_by_campaign") do
      with_bulk_hierarchy do |campaign_id, group_id|
        response = api.campaign_management.get_ad_groups_by_campaign_id(
          account_id: account_id,
          campaign_id: campaign_id,
          fields: ["Id", "Name"]
        )

        expect(response[:ad_groups].map { |group| group[:id] }).to include(group_id)
      end
    end
  end

  it "queries a seeded keyword by ad group" do
    use_json_api_cassette("queries_a_seeded_keyword_by_ad_group") do
      with_bulk_hierarchy do |_campaign_id, group_id, keyword_id|
        response = api.campaign_management.get_keywords_by_ad_group_id(
          account_id: account_id,
          ad_group_id: group_id,
          fields: ["Id", "Keyword", "Status"]
        )

        expect(response[:keywords].map { |keyword| keyword[:id] }).to include(keyword_id)
      end
    end
  end

  it "queries a seeded ad group by ID" do
    use_json_api_cassette("campaign_management_get_ad_groups_by_ids") do
      with_bulk_hierarchy do |campaign_id, group_id|
        response = api.campaign_management.get_ad_groups_by_ids(
          account_id: account_id,
          campaign_id: campaign_id,
          ad_group_ids: [group_id],
          fields: ["Id", "Name", "Status"]
        )

        expect(response[:ad_groups].first[:id]).to eq(group_id)
      end
    end
  end

  it "queries a seeded keyword by ID" do
    use_json_api_cassette("campaign_management_get_keywords_by_ids") do
      with_bulk_hierarchy do |_campaign_id, group_id, keyword_id|
        response = api.campaign_management.get_keywords_by_ids(
          account_id: account_id,
          ad_group_id: group_id,
          keyword_ids: [keyword_id],
          fields: ["Id", "Keyword", "Status"]
        )

        expect(response[:keywords].first[:id]).to eq(keyword_id)
      end
    end
  end
end
