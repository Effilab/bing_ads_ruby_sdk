# frozen_string_literal: true

RSpec.describe "JSON Ad Groups API" do
  include_context "json api with vcr"

  it "creates an ad group" do
    use_json_api_cassette("ad_groups_creates_ad_group") do
      with_campaign do |campaign_id|
        response = api.campaign_management.add_ad_groups(
          campaign_id: campaign_id,
          ad_groups: [{name: "SDK VCR Ad Group", status: "Paused", language: "English"}]
        )

        expect(response[:AdGroupIds]).not_to be_empty
      end
    end
  end

  it "updates an ad group" do
    use_json_api_cassette("ad_groups_updates_ad_group") do
      with_campaign_and_ad_group do |campaign_id, ad_group_id|
        response = api.campaign_management.update_ad_groups(
          campaign_id: campaign_id,
          ad_groups: [{id: ad_group_id, name: "SDK VCR Ad Group Updated", status: "Paused"}]
        )

        expect(response[:PartialErrors]).to eq([])
      end
    end
  end

  it "deletes an ad group" do
    use_json_api_cassette("ad_groups_deletes_ad_group") do
      with_campaign_and_ad_group do |campaign_id, ad_group_id|
        response = api.campaign_management.delete_ad_groups(
          campaign_id: campaign_id,
          ad_group_ids: [ad_group_id]
        )

        expect(response[:PartialErrors]).to eq([])
        @ad_group_deleted = true
      end
    end
  end
end
