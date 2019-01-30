require_relative '../examples'

RSpec.describe 'CampaignManagement service' do
  include_context 'use api'

  describe 'UET methods' do
    subject(:add_uet_tags) do
      api.campaign_management.add_uet_tags(
        uet_tags: [
          uet_tag: {
            description: 'UET Tag Description',
            name: "Acceptance Test UET Tag #{random}",
          }
        ]
      )
    end

    describe '#add_uet_tags' do
      it 'returns a list of newly created UET tags' do
        uet_tags = add_uet_tags
        expect(uet_tags).to include(
          uet_tags: {
            uet_tag: [
              {
                description: 'UET Tag Description',
                id: a_kind_of(String),
                name: a_string_starting_with('Acceptance Test UET Tag'),
                tracking_no_script: a_string_starting_with("<img src=\"//bat.bing.com/action/"),
                tracking_script: a_string_starting_with('<script>(function(w,d,t,r,u)'),
                tracking_status: 'Unverified',
              }
            ]
          },
          partial_errors: ''
        )

        puts "Please fill in examples.rb with uet_tag_id: #{uet_tags[:uet_tags][:uet_tag].first[:id]}"
      end
    end
  end
end
