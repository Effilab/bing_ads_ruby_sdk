module BingAdsRubySdk
  RSpec.describe Api do
    subject do
      described_class.new(environment: :test)
    end

    it { expect(subject.campaign_management).to be_instance_of(BingAdsRubySdk::Services::Base) }

    describe '.header' do
      it { expect(subject.header).to be_instance_of(BingAdsRubySdk::Header) }

      describe '.content' do
        it 'inits properly so the content is available' do
          expect(subject.header.content).to be_a(Hash)
        end
      end
    end
  end
end
