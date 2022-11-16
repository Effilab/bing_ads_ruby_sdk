# frozen_string_literal: true

require_relative '../examples'

RSpec.describe 'AdExtension methods' do
  include_context 'use api'

  def create_add_ad_extensions
    Examples.build_api.campaign_management.add_ad_extensions(
      account_id: Examples.account_id,
      ad_extensions: [
        {
          call_ad_extension: {
            country_code: 'NZ',
            is_call_only: false,
            phone_number: SecureRandom.random_number(999_999_999)
          }
        },
        {
          callout_ad_extension: {
            text: Examples.random[0..11]
          }
        },
        {
          sitelink_ad_extension: {
            description_1: "Description 1 - #{Examples.random}"[0..34],
            description_2: "Description 2 - #{Examples.random}"[0..34],
            display_text: "Display Text #{Examples.random}"[0..24],
            final_mobile_urls: [{ string: 'http://mobile.example.com' }],
            final_urls: [{ string: 'http://www.example.com' }],
            tracking_url_template: '{lpurl}'
          }
        }
      ]
    )
  end

  def set_ad_extensions_associations(ad_extension_ids)
    Examples.build_api.campaign_management.set_ad_extensions_associations(
      account_id: Examples.account_id,
      ad_extension_id_to_entity_id_associations: ad_extension_ids.map do |id|
        {
          ad_extension_id_to_entity_id_association: {
            ad_extension_id: id,
            entity_id: Examples.campaign_id
          }
        }
      end,
      association_type: 'Campaign'
    )
  end

  def ad_extension_ids(creation_response)
    creation_response[:ad_extension_identities][:ad_extension_identity].map do |ext|
      ext[:id].to_i
    end
  end

  def get_ad_extensions_associations
    api.campaign_management.get_ad_extensions_associations(
      account_id: Examples.account_id,
      ad_extension_type: 'CallAdExtension SitelinkAdExtension CalloutAdExtension',
      association_type: 'Campaign',
      entity_ids: [{ long: Examples.campaign_id }]
    )
  end

  context 'with shared ad extensions' do
    before(:all) do
      @created_ad_extension_response = create_add_ad_extensions
      set_ad_extensions_associations(ad_extension_ids(@created_ad_extension_response))
    end

    describe '#add_ad_extensions' do
      it 'returns AdExtension ids' do
        expect(@created_ad_extension_response).to include(
          ad_extension_identities: {
            ad_extension_identity: [
              { id: a_kind_of(String), version: '1' },
              { id: a_kind_of(String), version: '1' },
              { id: a_kind_of(String), version: '1' }
            ]
          },
          nested_partial_errors: ''
        )
      end
    end

    describe '#get_ad_extensions_associations' do
      let(:call_ad_extension) do
        {
          ad_extension: {
            device_preference: nil,
            forward_compatibility_map: '',
            id: match(/[0-9]*/),
            scheduling: nil,
            status: a_kind_of(String),
            type: 'CallAdExtension',
            version: match(/[0-9]*/),
            country_code: a_kind_of(String),
            is_call_only: 'false',
            is_call_tracking_enabled: 'false',
            phone_number: match(/[0-9]*/),
            require_toll_free_tracking_number: nil
          },
          association_type: 'Campaign',
          editorial_status: a_kind_of(String),
          entity_id: Examples.campaign_id.to_s
        }
      end

      let(:callout_ad_extension) do
        {
          ad_extension: {
            device_preference: nil,
            forward_compatibility_map: '',
            id: match(/[0-9]*/),
            scheduling: nil,
            status: a_kind_of(String),
            type: 'CalloutAdExtension',
            version: match(/[0-9]*/),
            text: a_kind_of(String)
          },
          association_type: 'Campaign',
          editorial_status: a_kind_of(String),
          entity_id: Examples.campaign_id.to_s
        }
      end

      let(:sitelink_ad_extension) do
        {
          ad_extension: {
            device_preference: nil,
            forward_compatibility_map: '',
            id: match(/[0-9]*/),
            status: a_kind_of(String),
            type: 'SitelinkAdExtension',
            version: match(/[0-9]*/),
            description1: a_kind_of(String),
            description2: a_kind_of(String),
            destination_url: nil,
            display_text: a_kind_of(String),
            final_app_urls: nil,
            final_url_suffix: nil,
            final_mobile_urls: {
              string: a_kind_of(String)
            },
            final_urls: {
              string: a_kind_of(String)
            },
            scheduling: nil,
            tracking_url_template: a_kind_of(String),
            url_custom_parameters: nil
          },
          association_type: 'Campaign',
          editorial_status: 'Active',
          entity_id: Examples.campaign_id.to_s
        }
      end

      def get_association(associations, type)
        associations.find { |record| record[:ad_extension][:type] == type }
      end

      it 'returns a list of Associations' do
        fetched_associations = get_ad_extensions_associations

        # These are split apart to make it easier to figure out which one is missing
        expect(get_association(fetched_associations, 'CallAdExtension'))
          .to include(call_ad_extension)

        expect(get_association(fetched_associations, 'CalloutAdExtension'))
          .to include(callout_ad_extension)

        expect(get_association(fetched_associations, 'SitelinkAdExtension'))
          .to include(sitelink_ad_extension)
      end
    end

    describe '#get_ad_extension_ids_by_account_id' do
      it 'returns a list of IDs' do
        fetched_ad_extension_ids = api.campaign_management.get_ad_extension_ids_by_account_id(
          account_id: Examples.account_id,
          ad_extension_type: 'SitelinkAdExtension CallAdExtension CalloutAdExtension'
        )
        ad_extension_ids(@created_ad_extension_response).each do |id|
          expect(fetched_ad_extension_ids).to include id
        end
      end
    end

    describe '#get_ad_extensions_by_ids' do
      it 'returns AdExtensions' do
        extensions = api.campaign_management.get_ad_extensions_by_ids(
          account_id: Examples.account_id,
          ad_extension_ids: ad_extension_ids(@created_ad_extension_response).map { |id| { long: id } },
          ad_extension_type: 'SitelinkAdExtension CallAdExtension CalloutAdExtension'
        )
        expect(extensions).to be_an(Array)
      end
    end
  end

  describe '#delete_ad_extensions' do
    let(:response) { create_add_ad_extensions }

    it 'returns no errors' do
      expect(api.campaign_management.call(:delete_ad_extensions,
                                          account_id: Examples.account_id,
                                          ad_extension_ids: [{ long: ad_extension_ids(response).first }])).to eq(partial_errors: '')
    end
  end

  describe '#delete_ad_extensions_associations' do
    before do
      response = create_add_ad_extensions
      set_ad_extensions_associations(ad_extension_ids(response))
    end
    let(:ad_extension_id) do
      get_ad_extensions_associations.first[:ad_extension][:id]
    end

    it 'currently raises an error' do
      expect(api.campaign_management.call(:delete_ad_extensions_associations,
                                          account_id: Examples.account_id,
                                          ad_extension_id_to_entity_id_associations: [
                                            ad_extension_id_to_entity_id_association: {
                                              ad_extension_id: ad_extension_id,
                                              entity_id: Examples.campaign_id
                                            }
                                          ],
                                          association_type: 'Campaign')).to eq(partial_errors: '')
    end
  end
end
