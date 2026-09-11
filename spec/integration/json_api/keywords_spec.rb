# frozen_string_literal: true

RSpec.describe "JSON Keywords API" do
  include_context "json api with vcr"

  it "creates a keyword" do
    use_json_api_cassette("keywords_creates_keyword") do
      with_bulk_hierarchy do |_campaign_id, group_id|
        response = api.campaign_management.add_keywords(
          ad_group_id: group_id,
          keywords: [{text: "sdk vcr direct keyword", match_type: "Exact", status: "Paused", bid: {amount: 0.1}}]
        )

        expect(response[:KeywordIds]).not_to be_empty
      end
    end
  end

  it "updates a keyword" do
    use_json_api_cassette("keywords_updates_keyword") do
      with_bulk_hierarchy do |_campaign_id, group_id, keyword_id|
        response = api.campaign_management.update_keywords(
          ad_group_id: group_id,
          keywords: [{id: keyword_id, status: "Paused", bid: {amount: 0.2}}]
        )

        expect(response[:PartialErrors]).to eq([])
      end
    end
  end

  it "queries keywords by editorial status" do
    use_json_api_cassette("keywords_queries_by_editorial_status") do
      with_bulk_hierarchy do |_campaign_id, group_id|
        keyword_response = api.campaign_management.add_keywords(
          ad_group_id: group_id,
          keywords: [{text: "sdk vcr editorial keyword", match_type: "Exact", status: "Paused", bid: {amount: 0.1}}]
        )
        keyword_id = keyword_response.fetch(:KeywordIds).first

        response = api.campaign_management.get_keywords_by_editorial_status(
          ad_group_id: group_id,
          editorial_status: "Active"
        )

        expect(response.fetch(:Keywords).map { |keyword| keyword[:Id] }).to include(keyword_id.to_s)
      end
    end
  end

  it "deletes a keyword" do
    use_json_api_cassette("keywords_deletes_keyword") do
      with_bulk_hierarchy do |_campaign_id, group_id, keyword_id|
        response = api.campaign_management.delete_keywords(
          ad_group_id: group_id,
          keyword_ids: [keyword_id]
        )

        expect(response[:PartialErrors]).to eq([])
        @keyword_deleted = true
      end
    end
  end
end
