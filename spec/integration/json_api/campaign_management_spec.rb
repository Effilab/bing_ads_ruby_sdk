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

        expect(response[:Campaigns]).not_to be_empty
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

        expect(response[:Campaigns].first[:Id]).to eq(campaign_id)
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

        expect(response[:Campaigns].first[:Id]).to eq(campaign_id)
      end
    end
  end

  it "creates a paused campaign" do
    use_json_api_cassette("campaign_management_add_campaigns") do
      with_campaign do |campaign_id, response|
        expect(response[:CampaignIds]).to include(campaign_id)
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

        expect(response[:PartialErrors]).to eq([])
        updated = api.campaign_management.get_campaigns_by_ids(
          account_id: account_id,
          campaign_ids: [campaign_id],
          fields: ["Id", "Name", "Status"]
        )
        expect(updated[:Campaigns].first[:Name]).to eq("SDK VCR Campaign Updated")
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

        expect(response[:PartialErrors]).to eq([])
        @campaign_deleted = true
        remaining = api.campaign_management.get_campaigns_by_account_id(
          account_id: account_id,
          fields: ["Id", "Name"]
        )
        expect(remaining[:Campaigns].none? { |campaign| campaign[:Name] == campaign_name }).to be(true)
      end
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

        expect(response[:AdGroups].map { |group| group[:Id] }).to include(group_id)
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

        expect(response[:Keywords].map { |keyword| keyword[:Id] }).to include(keyword_id)
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

        expect(response[:AdGroups].first[:Id]).to eq(group_id)
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

        expect(response[:Keywords].first[:Id]).to eq(keyword_id)
      end
    end
  end
end
