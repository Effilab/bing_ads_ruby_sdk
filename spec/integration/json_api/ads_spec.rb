# frozen_string_literal: true

RSpec.describe "JSON Ads API" do
  include_context "json api with vcr"

  it "completes the responsive search ad lifecycle" do
    use_json_api_cassette("ads_completes_responsive_search_ad_lifecycle") do
      with_campaign_and_ad_group do |campaign_id, ad_group_id|
        create_response = api.campaign_management.add_responsive_search_ads(
          ad_group_id: ad_group_id,
          headlines: [
            "SDK VCR headline one",
            "SDK VCR headline two",
            "SDK VCR headline three"
          ],
          descriptions: [
            "SDK VCR description one",
            "SDK VCR description two"
          ],
          final_urls: ["https://www.example.com/"],
          path1: "before",
          path2: "test"
        )
        ad_id = create_response.fetch(:AdIds).first
        expect(ad_id).not_to be_nil

        update_response = api.campaign_management.update_ads(
          ad_group_id: ad_group_id,
          ads: [{
            id: ad_id,
            type: "ResponsiveSearch",
            status: "Paused",
            path1: "after",
            path2: "test"
          }]
        )
        expect(update_response[:PartialErrors]).to eq([])

        updated_ads = api.campaign_management.get_ads_by_ad_group_id(
          ad_group_id: ad_group_id,
          ad_types: ["ResponsiveSearch"]
        ).fetch(:Ads, [])
        updated_ad = updated_ads.find { |ad| ad[:Id].to_s == ad_id.to_s }
        expect(updated_ad).to include(Id: ad_id.to_s, Type: "ResponsiveSearch", Path1: "after")

        delete_response = api.campaign_management.delete_ads(
          ad_group_id: ad_group_id,
          ad_ids: [ad_id]
        )
        expect(delete_response[:PartialErrors]).to eq([])

        remaining_ads = api.campaign_management.get_ads_by_ad_group_id(
          ad_group_id: ad_group_id,
          ad_types: ["ResponsiveSearch"]
        ).fetch(:Ads, [])
        expect(remaining_ads.map { |ad| ad[:Id].to_s }).not_to include(ad_id.to_s)

        api.campaign_management.delete_ad_groups(
          campaign_id: campaign_id,
          ad_group_ids: [ad_group_id]
        )
        @ad_group_deleted = true
      end
    end
  end
end
