require_relative '../examples'

RSpec.describe 'Keyword methods' do
  include_context 'use api'

  describe 'Keyword methods' do
    let(:a_keyword) do
      {
        bid: a_kind_of(Hash),
        bidding_scheme: a_kind_of(Hash),
        destination_url: a_kind_of(String),
        editorial_status: a_kind_of(String),
        final_app_urls: nil,
        final_mobile_urls: nil,
        final_urls: nil,
        forward_compatibility_map: a_kind_of(String),
        id: a_kind_of(String),
        match_type: a_kind_of(String),
        param1: a_kind_of(String),
        param2: a_kind_of(String),
        param3: a_kind_of(String),
        status: a_kind_of(String),
        text: a_kind_of(String),
        tracking_url_template: nil,
        url_custom_parameters: nil,
      }
    end

    let(:keyword_id) { add_keywords[:keyword_ids].first }
    let(:add_keywords) do
      api.campaign_management.call(:add_keywords,
        ad_group_id: Examples.ad_group_id,
        keywords: { keyword: {
          bid: { amount: 0.05 },
          match_type: 'Exact',
          text: "AcceptanceTestKeyword - #{random}",
        } }
      )
    end

    describe '#add_keywords' do
      it 'returns created Keyword ids' do
        expect(add_keywords).to include(
          keyword_ids: [a_kind_of(Integer)],
          partial_errors: ''
        )
      end
    end

    describe '#get_keywords_by_ad_group_id' do
      before { add_keywords }

      it 'returns a list of keywords' do
        expect(api.campaign_management.get_keywords_by_ad_group_id(
          ad_group_id: Examples.ad_group_id
        )).to include(a_keyword)
      end
    end

    describe '#get_keywords_by_editorial_status' do
      before { add_keywords }

      it 'returns a list of Keywords' do
        expect(api.campaign_management.get_keywords_by_editorial_status(
          ad_group_id: Examples.ad_group_id,
          editorial_status: 'Active'
        )).to include(a_keyword)
      end
    end

    describe '#get_keywords_by_ids' do
      before { add_keywords }

      it 'returns a list of Keywords' do
        expect(api.campaign_management.get_keywords_by_ids(
          ad_group_id: Examples.ad_group_id,
          keyword_ids: [{ long: keyword_id }]
        )).to include(a_keyword)
      end
    end

    describe '#update_keywords' do
      before { add_keywords }

      it 'updates the keyword' do
        expect(api.campaign_management.call(:update_keywords,
          ad_group_id: Examples.ad_group_id,
          keywords: { keyword: [
            id: keyword_id,
            bid: { amount: 0.50 },
          ] }
        )).to include(partial_errors: '')
      end
    end

    describe '#delete_keywords' do
      before { add_keywords }

      it 'returns no errors' do
        expect(api.campaign_management.call(:delete_keywords,
          ad_group_id: Examples.ad_group_id,
          keyword_ids: [{ long: keyword_id }]
        )).to eq(partial_errors: '')
      end
    end
  end
end
