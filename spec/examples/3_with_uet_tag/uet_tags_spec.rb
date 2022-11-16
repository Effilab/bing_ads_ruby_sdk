# frozen_string_literal: true

require_relative '../examples'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'

  describe 'UET methods' do
    let(:get_uet_tags_by_ids) do
      api.campaign_management.get_uet_tags_by_ids(
        tag_ids: [
          { long: Examples.uet_tag_id }
        ]
      )
    end

    describe '#get_uet_tags_by_ids' do
      it 'returns a list of UET tags' do
        expect(get_uet_tags_by_ids).to contain_exactly(
          {
            description: a_kind_of(String),
            id: a_kind_of(String),
            name: a_string_starting_with('Acceptance Test UET Tag'),
            tracking_no_script: a_string_starting_with('<img src="//bat.bing.com/action/'),
            tracking_script: a_string_starting_with('<script>(function(w,d,t,r,u)'),
            tracking_status: 'Unverified',
            customer_share: nil
          }
        )
      end
    end

    describe '#update_uet_tags' do
      subject do
        api.campaign_management.update_uet_tags({
                                                  uet_tags: [
                                                    {
                                                      uet_tag: {
                                                        name: "Acceptance Test UET Tag - #{random}",
                                                        id: Examples.uet_tag_id,
                                                        description: "UET Tag Description - #{random}"
                                                      }
                                                    }
                                                  ]
                                                })
      end

      it 'updates the UET tag fields' do
        is_expected.to eq(partial_errors: '')

        expect(get_uet_tags_by_ids.first).to include(
          name: "Acceptance Test UET Tag - #{random}",
          description: "UET Tag Description - #{random}"
        )
      end
    end
  end
end
