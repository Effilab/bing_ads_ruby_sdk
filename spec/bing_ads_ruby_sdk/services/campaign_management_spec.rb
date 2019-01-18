RSpec.describe BingAdsRubySdk::Services::CampaignManagement do

  let(:service_name) { described_class.service }
  let(:soap_client) { SpecHelpers.soap_client(service_name) }
  let(:expected_xml) { SpecHelpers.request_xml_for(service_name, action, filename) }
  let(:mocked_response) { SpecHelpers.response_xml_for(service_name, action, filename) }

  let(:service) { described_class.new(soap_client) }

  before do
    expect(BingAdsRubySdk::HttpClient).to receive(:post) do |req|
      expect(Nokogiri::XML(req.content).to_xml).to eq expected_xml.to_xml
      mocked_response
    end
  end

  describe "get_campaigns_by_account_id" do
    let(:action) { 'get_campaigns_by_account_id' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.get_campaigns_by_account_id(account_id: 150168726)
      ).to contain_exactly(
        a_hash_including(name: "20200015 - 20200015 - SN - B - Activité - Stations_Service - Geoloc - ETA"),
        a_hash_including(name: "20200015 - 20200015 - SN - E - Produits - Stations_Service - Geoloc - ETA"),
        a_hash_including(name: "20200015 - SN - X - Station Service #1 - Geozone_custom - 5KW - V3 - ETA")
      )
    end
  end

  describe "get_budgets_by_ids" do
    let(:action) { 'get_budgets_by_ids' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.get_budgets_by_ids
      ).to contain_exactly(
        a_hash_including(name: "budget_DEFAULT"),
      )
    end
  end

  describe "add_uet_tags" do
    let(:action) { 'add_uet_tags' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.add_uet_tags({ uet_tags: [ { uet_tag: { name: 'SDK-test', description: nil }}]})
      ).to include({
        uet_tags: a_hash_including({
          uet_tag: a_collection_containing_exactly(
            a_hash_including(name: "SDK-test")
          )
        }),
        partial_errors: ""
      })
    end
  end

  describe "update_uet_tags" do
    let(:action) { 'update_uet_tags' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.update_uet_tags({ uet_tags: [ { uet_tag: { name: 'updated SDK-test', id: 96031109, description: nil}}]})
      ).to eq({
        partial_errors: ""
      })
    end
  end

  describe "get_uet_tags_by_ids" do
    let(:action) { 'get_uet_tags_by_ids' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.get_uet_tags_by_ids(tag_ids: [{ long: 96031109 }])
      ).to contain_exactly(
        a_hash_including(name: "updated SDK-test")
      )
    end
  end

  describe "add_conversion_goals" do
    let(:action) { 'add_conversion_goals' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.add_conversion_goals(conversion_goals: [{
          conversion_goal: {
            '@type' => 'EventGoal',
            action_expression: 'contact_form',
            action_operator: 'Equals',
            conversion_window_in_minutes: 43200,
            count_type: "Unique",
            name: "sdk test",
            revenue: { "type": "NoValue" },
            type: "Event",
            tag_id: 96031109
          }
      }])).to eq({
        conversion_goal_ids: [46068449],
        partial_errors: ""
      })
    end
  end

  describe "update_conversion_goals" do
    let(:action) { 'update_conversion_goals' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.update_conversion_goals(conversion_goals: [{
          conversion_goal: {
            '@type' => 'EventGoal',
            id: 46068449,
            action_expression: 'contact_form',
            action_operator: 'Equals',
            conversion_window_in_minutes: 43200,
            count_type: "Unique",
            name: "updated sdk test",
            revenue: { "type": "NoValue" },
            type: "Event",
            tag_id: 96031109
          }
      }])).to eq({
        partial_errors: ""
      })
    end
  end

  describe "get_conversion_goals_by_ids" do
    let(:action) { 'get_conversion_goals_by_ids' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.get_conversion_goals_by_ids(
          conversion_goal_types: "Event",
          conversion_goal_ids: [{ long: 46068449 }, { long: 46068448 }]
        )
      ).to contain_exactly(
        a_hash_including(name: "updated sdk test"),
        a_hash_including(name: "random")
      )
    end
  end

  describe "add_ad_extensions" do
    let(:action) { 'add_ad_extensions' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.add_ad_extensions(
          account_id: 150168726,
          ad_extensions: [
            {
              ad_extension: {
                '@type' => 'CallAdExtension',
                scheduling: {},
                country_code: "NZ",
                phone_number: "0123456699",
              }
            }
          ]
      )).to include({
        ad_extension_identities: a_hash_including({
          ad_extension_identity: a_collection_containing_exactly(
            a_hash_including(id: "8177660966625")
          )
        }),
        nested_partial_errors: ""
      })
    end
  end

  describe "get_ad_extension_ids_by_account_id" do
    let(:action) { 'get_ad_extension_ids_by_account_id' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.get_ad_extension_ids_by_account_id(
          account_id: 150168726,
          ad_extension_type: "CallAdExtension SitelinkAdExtension CalloutAdExtension"
        )
      ).to eq([
        8177660966625
      ])
    end
  end

  describe "set_ad_extensions_associations" do
    let(:action) { 'set_ad_extensions_associations' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.set_ad_extensions_associations(
          account_id: 150168726,
          ad_extension_id_to_entity_id_associations: [{
            ad_extension_id_to_entity_id_association: {
              ad_extension_id: 8177660966942,
              entity_id: 349704437
            }
          }],
          association_type: "Campaign"
      )).to eq({
        partial_errors: ""
      })
    end
  end

  describe "get_ad_extensions_associations" do
    let(:action) { 'get_ad_extensions_associations' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.get_ad_extensions_associations(
          account_id: 150168726,
          association_type: "Campaign",
          ad_extension_type: "CalloutAdExtension",
          entity_ids: [ { long: 349704437 }]
        )
      ).to contain_exactly(
        a_hash_including(
          ad_extension: a_hash_including(id: '8177650858590', text: "Informations Et Contact")
        ),
        a_hash_including(
          ad_extension: a_hash_including(id: '8177660966942', text: "CalloutText")
        )
      )
    end
  end

  describe "add_shared_entity" do
    let(:action) { 'add_shared_entity' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.add_shared_entity(
          shared_entity: {
            '@type' => 'NegativeKeywordList',
            name: 'sdk list'
          }
      )).to eq({
        list_item_ids: "",
        partial_errors: "",
        shared_entity_id: "229798145242911"
      })
    end
  end

  describe "get_shared_entities_by_account_id" do
    let(:action) { 'get_shared_entities_by_account_id' }
    let(:filename) { 'standard' }

    it "returns expected result" do
      expect(
        service.get_shared_entities_by_account_id(
          shared_entity_type: "NegativeKeywordList"
      )).to contain_exactly(
        a_hash_including(id: '229798145242911', name: "sdk list")
      )
    end
  end
end
