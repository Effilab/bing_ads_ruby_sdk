RSpec.describe BingAdsRubySdk::Api do
  subject do
    described_class.new(
      environment: :test,
      oauth_store: SpecHelpers.default_store,
      client_id: 'client_id',
      developer_token: 'developer_token'
    )
  end

  it { expect(subject.ad_insight).to be_a(BingAdsRubySdk::Services::AdInsight) }
  it { expect(subject.bulk).to be_a(BingAdsRubySdk::Services::Bulk) }
  it { expect(subject.campaign_management).to be_a(BingAdsRubySdk::Services::CampaignManagement) }
  it { expect(subject.customer_billing).to be_a(BingAdsRubySdk::Services::CustomerBilling) }
  it { expect(subject.customer_management).to be_a(BingAdsRubySdk::Services::CustomerManagement) }
  it { expect(subject.reporting).to be_a(BingAdsRubySdk::Services::Reporting) }
end