# frozen_string_literal: true

RSpec.describe "JSON Ad Extensions API" do
  include_context "json api with vcr"

  it "creates a callout extension" do
    use_json_api_cassette("ad_extensions_creates_callout_extension") do
      with_ad_extension do |extension_id, response|
        expect(response[:AdExtensionIdentities].map { |identity| identity[:Id] }).to include(extension_id)
      end
    end
  end

  it "reads a callout extension by ID" do
    use_json_api_cassette("ad_extensions_reads_callout_extension") do
      with_ad_extension do |extension_id|
        response = api.campaign_management.get_ad_extensions_by_ids(
          account_id: account_id,
          ad_extension_ids: [extension_id],
          ad_extension_type: "CalloutAdExtension"
        )

        expect(response[:AdExtensions].first[:Id]).to eq(extension_id)
      end
    end
  end

  it "lists callout extension IDs" do
    use_json_api_cassette("ad_extensions_lists_callout_extension_ids") do
      with_ad_extension do |extension_id|
        response = api.campaign_management.get_ad_extension_ids_by_account_id(
          account_id: account_id,
          ad_extension_type: "CalloutAdExtension"
        )

        expect(response[:AdExtensionIds]).to include(extension_id)
      end
    end
  end

  it "deletes a callout extension" do
    use_json_api_cassette("ad_extensions_deletes_callout_extension") do
      with_ad_extension do |extension_id|
        response = api.campaign_management.delete_ad_extensions(
          account_id: account_id,
          ad_extension_ids: [extension_id]
        )

        expect(response[:PartialErrors]).to eq([])
        @ad_extension_deleted = true
      end
    end
  end

  it "associates and disassociates a callout extension" do
    use_json_api_cassette("ad_extensions_associates_and_disassociates_callout") do
      with_campaign do |campaign_id|
        with_ad_extension do |extension_id|
          association = {
            account_id: account_id,
            ad_extension_id_to_entity_id_associations: [
              {ad_extension_id: extension_id, entity_id: campaign_id}
            ],
            association_type: "Campaign"
          }
          set_response = api.campaign_management.set_ad_extensions_associations(association)
          expect(set_response[:PartialErrors]).to eq([])

          queried = api.campaign_management.get_ad_extensions_associations(
            account_id: account_id,
            ad_extension_type: "CalloutAdExtension",
            association_type: "Campaign",
            entity_ids: [campaign_id]
          )
          expect(queried[:AdExtensionAssociationCollection]).not_to be_empty

          delete_response = api.campaign_management.delete_ad_extensions_associations(association)
          expect(delete_response[:PartialErrors]).to eq([])
        end
      end
    end
  end

  it "creates reads deletes a call extension" do
    use_json_api_cassette("ad_extensions_lifecycle_call") do
      with_ad_extension(
        extension: {
          type: "CallAdExtension",
          country_code: "FR",
          is_call_only: false,
          phone_number: "+33155555555"
        }
      ) do |extension_id|
        fetched = api.campaign_management.get_ad_extensions_by_ids(
          account_id: account_id,
          ad_extension_ids: [extension_id],
          ad_extension_type: "CallAdExtension"
        )
        expect(fetched[:AdExtensions].first).to include(
          Id: extension_id,
          Type: "CallAdExtension",
          CountryCode: "FR"
        )

        response = api.campaign_management.delete_ad_extensions(
          account_id: account_id,
          ad_extension_ids: [extension_id]
        )
        expect(response[:PartialErrors]).to eq([])
        @ad_extension_deleted = true
      end
    end
  end

  it "creates reads deletes a sitelink extension" do
    use_json_api_cassette("ad_extensions_lifecycle_sitelink") do
      with_ad_extension(
        extension: {
          type: "SitelinkAdExtension",
          description1: "SDK VCR description one",
          description2: "SDK VCR description two",
          display_text: "SDK VCR Sitelink",
          final_urls: ["https://www.example.com/"],
          tracking_url_template: "{lpurl}"
        }
      ) do |extension_id|
        fetched = api.campaign_management.get_ad_extensions_by_ids(
          account_id: account_id,
          ad_extension_ids: [extension_id],
          ad_extension_type: "SitelinkAdExtension"
        )
        expect(fetched[:AdExtensions].first).to include(
          Id: extension_id,
          Type: "SitelinkAdExtension",
          DisplayText: "SDK VCR Sitelink"
        )

        response = api.campaign_management.delete_ad_extensions(
          account_id: account_id,
          ad_extension_ids: [extension_id]
        )
        expect(response[:PartialErrors]).to eq([])
        @ad_extension_deleted = true
      end
    end
  end
end
