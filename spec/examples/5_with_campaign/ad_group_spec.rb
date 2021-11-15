require_relative "../examples"

RSpec.describe "AdGroup methods" do
  include_context "use api"

  describe "#add_ad_groups" do
    it "returns created AdGroup ids" do
      ad_groups = api.campaign_management.call(:add_ad_groups,
        campaign_id: Examples.campaign_id,
        ad_groups: {
          ad_group: {
            name: "AcceptanceTestAdGroup - #{random}",
            language: "French",
            start_date: {
              day: "1",
              month: "1",
              year: "2049"
            },
            end_date: {
              day: "1",
              month: "2",
              year: "2049"
            }
          }
        })
      expect(ad_groups).to include(
        ad_group_ids: [a_kind_of(Integer)],
        partial_errors: ""
      )

      puts "Please fill in examples.rb with ad_group_id: #{ad_groups[:ad_group_ids].first}"
    end
  end
end
