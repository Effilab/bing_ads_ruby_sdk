# frozen_string_literal: true

RSpec.describe "JSON UET Tags API" do
  include_context "json api with vcr"

  let(:uet_tag_id) { 211077200 }

  it "creates a UET tag" do
    use_json_api_cassette("uet_tags_creates_tag") do
      response = api.campaign_management.add_uet_tags(
        uet_tags: [{
          name: "SDK VCR UET #{SecureRandom.hex(4)}",
          description: "SDK VCR integration tag"
        }]
      )

      expect(response[:UetTags]).to include(
        a_hash_including(:Id, :Name, Description: "SDK VCR integration tag")
      )
    end
  end

  it "reads an existing UET tag" do
    use_json_api_cassette("uet_tags_reads_existing_tag") do
      response = api.campaign_management.get_uet_tags_by_ids(uet_tag_ids: [uet_tag_id])

      expect(response[:UetTags]).not_to be_empty
    end
  end

  it "updates an existing UET tag" do
    use_json_api_cassette("uet_tags_updates_existing_tag") do
      response = api.campaign_management.update_uet_tags(
        uet_tags: [{id: uet_tag_id, name: "SDK VCR Existing UET", description: "SDK VCR update"}]
      )

      expect(response[:PartialErrors]).to eq([])
    end
  end
end
