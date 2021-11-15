require_relative "../examples"

RSpec.describe "CampaignManagement service" do
  include_context "use api"

  describe "Campaign methods" do
    let(:a_campaign_hash) do
      a_hash_including(
        audience_ads_bid_adjustment: a_kind_of(String),
        bidding_scheme: a_kind_of(Hash),
        budget_type: a_kind_of(String),
        daily_budget: a_kind_of(String),
        forward_compatibility_map: "",
        id: Examples.campaign_id.to_s,
        name: a_string_starting_with("Acceptance Test Campaign"),
        status: a_kind_of(String),
        time_zone: a_kind_of(String),
        tracking_url_template: nil,
        url_custom_parameters: nil,
        campaign_type: a_kind_of(String),
        settings: nil,
        budget_id: nil,
        languages: nil,
        experiment_id: nil,
        final_url_suffix: nil,
        sub_type: nil
      )
    end

    describe "#get_campaigns_by_account_id" do
      it "returns a list of campaigns" do
        expect(api.campaign_management.get_campaigns_by_account_id(
          account_id: Examples.account_id
        )).to include(a_campaign_hash)
      end
    end

    describe "#get_campaigns_by_ids" do
      it "returns a list of campaigns" do
        expect(api.campaign_management.get_campaigns_by_ids(
          account_id: Examples.account_id,
          campaign_ids: [{long: Examples.campaign_id}]
        )).to include(a_campaign_hash)
      end
    end

    describe "#update_campaigns" do
      subject do
        api.campaign_management.call(:update_campaigns,
          account_id: Examples.account_id,
          campaigns: {
            campaign: [
              id: Examples.campaign_id,
              name: "Acceptance Test Campaign - #{random}"
            ]
          })
      end

      it "returns no errors" do
        is_expected.to eq(partial_errors: "")
        updated_campaign = api.campaign_management.get_campaigns_by_ids(
          account_id: Examples.account_id,
          campaign_ids: [{long: Examples.campaign_id}]
        ).first

        expect(updated_campaign).to include(name: "Acceptance Test Campaign - #{random}")
      end
    end
  end
end
