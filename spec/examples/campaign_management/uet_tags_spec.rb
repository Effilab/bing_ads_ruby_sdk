require_relative '../example_helper'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'

  describe 'UET methods' do
    subject(:add_uet_tags) do
      api.campaign_management.add_uet_tags(
        uet_tags: {
          uet_tag: {
            description: 'UET Tag Description',
            name: "Acceptance Test UET Tag #{SecureRandom.hex}",
          },
        }
      )
    end

    subject(:get_uet_tags_by_ids) do
      api.campaign_management.get_uet_tags_by_ids(
        tag_ids: [
          { long: uet_tag[:id] },
        ]
      )
    end

    let(:a_uet_tag_list) do
      {
        uet_tags: {
          uet_tag: [
            {
              description: 'UET Tag Description',
              id: a_kind_of(String),
              name: a_string_starting_with('Acceptance Test UET Tag'),
              tracking_no_script: a_string_starting_with("<img src=\"//bat.bing.com/action/"),
              tracking_script: a_string_starting_with('<script>(function(w,d,t,r,u)'),
              tracking_status: 'Unverified',
            },
          ],
        },
        partial_errors: '',
      }
    end

    let(:uet_tag) { add_uet_tags[:uet_tags][:uet_tag].first }

    describe '#add_uet_tags' do
      it 'returns a list of newly created UET tags' do
        expect(add_uet_tags).to include(a_uet_tag_list)
      end
    end

    describe '#get_uet_tags_by_ids' do
      it 'returns a list of UET tags' do
        expect(get_uet_tags_by_ids).to include(a_uet_tag_list)
      end
    end

    describe '#update_uet_tags' do
      let(:updated_uet_tag_list) do
        add_uet_tags.tap do |list|
          tag = list[:uet_tags][:uet_tag].first
          tag[:description] = "#{tag[:description]} - updated"
        end
      end

      subject do
        api.campaign_management.update_uet_tags(updated_uet_tag_list)
      end

      it 'updates the UET tag fields' do
        is_expected.to eq(partial_errors: '')

        expect(get_uet_tags_by_ids[:uet_tags][:uet_tag].first).to include(
          description: 'UET Tag Description - updated'
        )
      end
    end
  end
end
