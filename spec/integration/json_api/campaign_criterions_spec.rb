# frozen_string_literal: true

RSpec.describe "JSON Campaign Criterions API" do
  include_context "json api with vcr"

  it "creates a location criterion" do
    use_json_api_cassette("campaign_criterions_creates_location_criterion") do
      with_campaign_criterion do |criterion_id, _campaign_id, response|
        expect(response[:CampaignCriterionIds]).to include(criterion_id)
      end
    end
  end

  it "reads a location criterion" do
    use_json_api_cassette("campaign_criterions_reads_location_criterion") do
      with_campaign_criterion do |criterion_id, campaign_id|
        response = api.campaign_management.get_campaign_criterions_by_ids(
          campaign_criterion_ids: [criterion_id],
          campaign_id: campaign_id,
          criterion_type: "Location"
        )

        expect(response[:CampaignCriterions].first[:Id]).to eq(criterion_id)
      end
    end
  end

  it "deletes a location criterion" do
    use_json_api_cassette("campaign_criterions_deletes_location_criterion") do
      with_campaign_criterion do |criterion_id, campaign_id|
        response = api.campaign_management.delete_campaign_criterions(
          campaign_criterion_ids: [criterion_id],
          campaign_id: campaign_id,
          criterion_type: "Targets"
        )

        expect(response[:PartialErrors]).to eq([])
        @criterion_deleted = true
      end
    end
  end
end
