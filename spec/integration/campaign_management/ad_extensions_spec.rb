# frozen_string_literal: true

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

    subject(:get_ad_extensions) do
      api.campaign_management.get_ad_extensions_by_ids(
        account_id: ACCOUNT_ID,
        ad_extension_ids: [{ long: id }],
        ad_extension_type: types
      )
    end

    let(:ad_extension_ids) do
      get_ad_extensions_by_account_id[:ad_extension_ids]
    end

    let(:extension_id) { add_ad_extensions[:ad_extension_identities][:ad_extension_identity].first[:id] }

    subject(:set_ad_extensions_associations) do
      api.campaign_management.set_ad_extensions_associations(
        account_id: ACCOUNT_ID,
        ad_extension_id_to_entity_id_associations: {
          ad_extension_id_to_entity_id_association: [
            {
              ad_extension_id: extension_id,
              entity_id: campaign_id,
            },
          ],
        },
        association_type: "Campaign"
      )
    end

    describe "#add_ad_extensions" do
      subject { add_ad_extensions }

      it "returns AdExtension ids" do
        is_expected.to include(
          ad_extension_identities: {
            ad_extension_identity: [
              id: a_kind_of(String),
              version: "1",
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

      subject(:get_ad_extensions_associations) do
        api.campaign_management.get_ad_extensions_associations(
          account_id: ACCOUNT_ID,
          ad_extension_type: "CallAdExtension",
          association_type: "Campaign",
          entity_ids: { long: campaign_id }
        )
      end

      it "returns a list of Associations" do
        is_expected.to include(
          ad_extension_association_collection: {
            ad_extension_association_collection: [
              {
                ad_extension_associations: {
                  ad_extension_association: [
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
                    },
                  ],
                },
              },
            ],
          },
          partial_errors: ""
        )
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
        get_ad_extensions[:ad_extensions][:ad_extension].first
      end

      it "returns AdExtensions" do
        is_expected.to include(
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
      let(:ad_extension) { get_ad_extensions[:ad_extensions][:ad_extension].first }
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
