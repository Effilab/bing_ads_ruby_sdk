require 'spec_helper'
require 'byebug'

module BingAdsRubySdk
  RSpec.describe Configuration do
    subject do
      described_class.new(version: :v11, environment: :test)
    end

    it { expect(subject.data.keys).to eq %w[ABSTRACT PRODUCTION SANDBOX TEST] }
    it { expect(subject.version).to eq :v11 }
    it { expect(subject.environment).to eq :test }
    it do
      expect(
        subject.cache_path
      ).to eq File.join(Configuration::CACHE_BASE, '.cache', 'v11', 'test')
    end
    it { expect(subject.abstract.keys).to eq ['customer_management', 'campaign_management', 'reporting'] }
    it do
      expect(
        subject.services
      ).to eq({
        "ad_insight"=>"https://adinsight.api.bingads.microsoft.com/Api/Advertiser/AdInsight/v11/AdInsightService.svc?singleWsdl",
        "bulk"=>"https://bulk.api.bingads.microsoft.com/Api/Advertiser/CampaignManagement/v11/BulkService.svc?singleWsdl",
        "campaign_management"=>"https://campaign.api.bingads.microsoft.com/Api/Advertiser/CampaignManagement/v11/CampaignManagementService.svc?singleWsdl",
        "customer_billing"=>"https://clientcenter.api.bingads.microsoft.com/Api/Billing/v11/CustomerBillingService.svc?singleWsdl",
        "customer_management"=>"https://clientcenter.api.bingads.microsoft.com/Api/CustomerManagement/v11/CustomerManagementService.svc?singleWsdl",
        "reporting"=>"https://reporting.api.bingads.microsoft.com/Api/Advertiser/Reporting/v11/ReportingService.svc?singleWsdl"
      })
    end

    describe '.all' do
      it { expect { |block| Configuration.all(&block) }.to yield_with_args(BingAdsRubySdk::Configuration) }
      it { expect { |block| Configuration.all(&block) }.to yield_control.once }
    end
  end
end
