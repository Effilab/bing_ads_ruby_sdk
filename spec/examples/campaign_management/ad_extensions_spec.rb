# frozen_string_literal: true

require_relative '../example_helper'
require "securerandom"

RSpec.describe "CampaignManagement service" do
  include_context "use api"
  include_context "manages campaigns"

  describe "AdExtension methods" do
    subject(:add_ad_extensions) do
      api.campaign_management.add_ad_extensions(
        account_id: ACCOUNT_ID,
        ad_extensions: [
          {
            call_ad_extension: {
              device_preference: nil,
              id: nil,
              scheduling: {},
              country_code: "NZ",
              is_call_only: false,
              phone_number: SecureRandom.random_number(999_999_999),
            },
            callout_ad_extension: {
              device_preference: nil,
              id: nil,
              scheduling: {},
              text: "CalloutText",
            },
            site_links_ad_extension: {
              device_preference: nil,
              id: nil,
              site_links: [
                site_link: {
                  description_1: "Description 1",
                  description_2: "Description 2",
                  # destination_url: "Url", # Both Destination and Final Urls not allowed
                  display_text: "Display Text",
                  final_mobile_urls: [string: "http://mobile.example.com"],
                  final_urls: [string: "http://www.example.com"],
                  scheduling: {},
                  tracking_url_template: "{lpurl}",
                  url_custom_parameters: [
                    parameters: {
                      custom_parameter: [key: "Key", value: "Value"]
                    }
                  ]
              }]
            },
          },
        ]
      )
    end

    subject(:get_ad_extensions_by_account_id) do
      api.campaign_management.get_ad_extension_ids_by_account_id(
        account_id: ACCOUNT_ID,
        ad_extension_type: "CallAdExtension",
        association_type: nil
      )
    end

    let(:types) do
      # As of writing Sitelink2AdExtension is a pilot that you need to be signed up for to use here
      %w(
        SiteLinksAdExtension
        LocationAdExtension
        CallAdExtension
        ImageAdExtension
        AppAdExtension
        ReviewAdExtension
        CalloutAdExtension
        StructuredSnippetAdExtension
      ).join(" ")
    end

    subject(:get_ad_extensions_by_ids) do
      api.campaign_management.get_ad_extensions_by_ids(
        account_id: ACCOUNT_ID,
        ad_extension_ids: [{ long: id }],
        ad_extension_type: types
      )
    end

    let(:ad_extension_ids) do
      get_ad_extensions_by_account_id[:ad_extension_ids]
    end

    let(:extensions) { add_ad_extensions[:ad_extension_identities][:ad_extension_identity] }

    subject(:set_ad_extensions_associations) do
      api.campaign_management.set_ad_extensions_associations(
        account_id: ACCOUNT_ID,
        ad_extension_id_to_entity_id_associations:
            extensions.map do |extension|
              {
                ad_extension_id_to_entity_id_association: {
                  ad_extension_id: extension[:id],
                  entity_id: campaign_id,
                }
              }
            end,
        association_type: "Campaign"
      )
    end

    subject(:get_ad_extensions_associations) do
      api.campaign_management.get_ad_extensions_associations(
        account_id: ACCOUNT_ID,
        ad_extension_type: "CallAdExtension SiteLinksAdExtension CalloutAdExtension",
        association_type: "Campaign",
        entity_ids: { long: campaign_id }
      )
    end

    describe "#add_ad_extensions" do
      subject { add_ad_extensions }

      it "returns AdExtension ids" do
        is_expected.to include(
          ad_extension_identities: {
            ad_extension_identity: [
              { id: a_kind_of(String), version: "1" },
              { id: a_kind_of(String), version: "1" },
              { id: a_kind_of(String), version: "1" },
            ],
          },
          nested_partial_errors: ""
        )
      end
    end

    describe "#set_ad_extensions_associations" do
      it { expect(set_ad_extensions_associations).to eq(partial_errors: "") }
    end

    describe "#get_ad_extensions_associations" do
      before { set_ad_extensions_associations }

      let(:call_ad_extension) do
        {
          ad_extension: {
            device_preference: nil,
            forward_compatibility_map: "",
            id: match(/[0-9]*/),
            scheduling: nil,
            status: "Active",
            type: "CallAdExtension",
            version: match(/[0-9]*/),
            country_code: "NZ",
            is_call_only: "false",
            is_call_tracking_enabled: "false",
            phone_number: match(/[0-9]*/),
            require_toll_free_tracking_number: nil,
          },
          association_type: "Campaign",
          editorial_status: "Active",
          entity_id: campaign_id.to_s,
        }
      end

      let(:callout_ad_extension) do
        {
          ad_extension: {
            device_preference: nil,
            forward_compatibility_map: "",
            id: match(/[0-9]*/),
            scheduling: nil,
            status: "Active",
            type: "CalloutAdExtension",
            version: match(/[0-9]*/),
            text: "CalloutText"
          },
          association_type: "Campaign",
          editorial_status: "Active",
          entity_id: match(/[0-9]*/)
        }
      end

      let(:site_links_ad_extension) do
        {
          ad_extension: {
            device_preference: nil,
            forward_compatibility_map: "",
            id: match(/[0-9]*/),
            scheduling: nil,
            status: "Active",
            type: "SiteLinksAdExtension",
            version: match(/[0-9]*/),
            site_links: {
              site_link: {
                description1: "Description 1",
                description2: "Description 2",
                destination_url: nil,
                device_preference: nil,
                display_text: "Display Text",
                final_app_urls: nil,
                final_mobile_urls: {
                  string: "http://mobile.example.com"
                },
                final_urls: {
                  string: "http://www.example.com"
                },
                scheduling: nil,
                tracking_url_template: "{lpurl}",
                url_custom_parameters: {
                  parameters: {
                    custom_parameter: {
                      key: "Key",
                      value: "Value"
                    }
                  }
                }
              }
            }
          },
          association_type: "Campaign",
          editorial_status: "Active",
          entity_id: match(/[0-9]*/),
        }
      end

      let(:associations) do
        get_ad_extensions_associations[
          :ad_extension_association_collection][
          :ad_extension_association_collection].first[
          :ad_extension_associations][
          :ad_extension_association]
      end

      let(:result_site_link_association) do

      end

      def get_association(associations, type)
        associations.select { |record| record[:ad_extension][:type] == type }.first
      end

      it "returns a list of Associations" do
        expect(get_ad_extensions_associations).to include(
          ad_extension_association_collection: {
            ad_extension_association_collection: [
              {
                ad_extension_associations: {
                  ad_extension_association: a_kind_of(Array)
                }
              }
            ],
          },
          partial_errors: ""
        )

        # These are split apart to make it easier to figure out which one is missing
        expect(get_association(associations, "CallAdExtension"))
          .to include(call_ad_extension)

        expect(get_association(associations, "CalloutAdExtension"))
          .to include(callout_ad_extension)

        expect(get_association(associations, "SiteLinksAdExtension"))
          .to include(site_links_ad_extension)
      end
    end

    describe "#delete_ad_extensions_associations" do
      before { set_ad_extensions_associations }

      let(:ad_extension) do
        # This very deep hash is defined on the Bing API
        get_ad_extensions_associations[
          :ad_extension_association_collection][
          :ad_extension_association_collection]
          .first[:ad_extension_associations][
          :ad_extension_association].first[:ad_extension]
      end

      let(:ad_extension_id) { ad_extension[:id] }

      subject(:delete_ad_extensions_associations) do
        api.campaign_management.delete_ad_extensions_associations(
          account_id: ACCOUNT_ID,
          ad_extension_id_to_entity_id_associations: [
            ad_extension_id_to_entity_id_association: {
              ad_extension_id: ad_extension_id,
              entity_id: campaign_id,
            }
          ],
          association_type: "Campaign"
        )
      end

      it "currently raises an error" do
        is_expected.to eq(partial_errors: "")
      end
    end

    describe "#get_ad_extensions_by_account_id" do
      before { add_ad_extensions }

      it "returns a list of IDs" do
        expect(get_ad_extensions_by_account_id)
          .to include(ad_extension_ids: a_collection_including(a_kind_of(Integer)))
      end
    end

    describe "#delete_ad_extensions" do
      before { add_ad_extensions }

      subject do
        api.campaign_management.delete_ad_extensions(
          account_id: ACCOUNT_ID,
          ad_extension_ids: [
            { long: ad_extension_ids.first },
          ],
          # To delete all AdExtensions you could use the following
          # ad_extension_ids: ad_extension_ids.map { |id | { long: id } },
        )
      end

      it "returns no errors" do
        is_expected.to eq(partial_errors: "")
      end
    end

    describe "#get_ad_extensions_by_ids" do
      before { add_ad_extensions }

      let(:id) { add_ad_extensions[:ad_extension_identities][:ad_extension_identity].first[:id] }

      let(:ad_extension_item) do
        get_ad_extensions_by_ids[:ad_extensions][:ad_extension].first
      end

      it "returns AdExtensions" do
        expect(get_ad_extensions_by_ids).to include(
          ad_extensions: {
            ad_extension: a_kind_of(Array),
          },
          partial_errors: ""
        )

        expect(ad_extension_item).to include(
          device_preference: nil,
          forward_compatibility_map: "",
          id: match_regex(/[0-9]*/),
          phone_number: match_regex(/[0-9]*/),
          require_toll_free_tracking_number: nil
        )
      end
    end

    describe "#update_ad_extensions" do
      before { add_ad_extensions }

      let(:id) { add_ad_extensions[:ad_extension_identities][:ad_extension_identity].first[:id] }
      let(:ad_extension) { get_ad_extensions_by_ids[:ad_extensions][:ad_extension].first }
      let(:updated_ad_extension) do
        ad_extension
          .merge(phone_number: "111111111")
          .delete_if { |key| key == :version } # Version is read-only
      end

      subject do
        api.campaign_management.update_ad_extensions(
          account_id: ACCOUNT_ID,
          ad_extensions: [call_ad_extension: updated_ad_extension]
        )
      end

      it "returns no errors" do
        is_expected.to eq(nested_partial_errors: "")
      end
    end
  end
end
