require 'spec_helper'
require 'fixtures'

module BingAdsRubySdk
  RSpec.describe Service do
    before(:all) do
      SoapCallbackManager.register_callbacks
    end

    let(:header) do
      double('header').tap do |header|
        allow(header).to receive(:content) do
          {
            authentication_token: 'yes/we/can',
            developer_token:      '123abc',
            customer_id:          777,
            customer_account_id:  666
          }
        end
      end
    end

    subject do
      described_class.new(
        Fixtures.lol_campaign_management,
        header
      )
    end

    it { expect(subject.operations.size).to eq 99 }

    describe '.request' do
      before do
        allow(subject).to receive(:http_request).and_wrap_original { |_, req| req }
        allow(subject).to receive(:parse_response).and_wrap_original { |_, req, raw| req }
      end

      it { expect(subject.add_campaign_criterions.content.empty?).to be false }

      context 'concurrent' do
        before do
          Thread.new do
            SoapCallbackManager.register_callbacks
            @doc1 = subject.add_campaign_criterions(
              campaign_criterions: {
                campaign_criterion: {
                  location_criterion: {
                    location_id: 93_100, display_name: 'Montreuil'
                  }
                }
              }
            ).envelope.doc
          end.join
        end

        it do
          expect(
            @doc1.at_xpath(
              '/soap:Envelope'\
                '/soap:Body'\
                  '/ns0:AddCampaignCriterionsRequest'\
                    '/ns0:CampaignCriterions'\
                      '/ns0:CampaignCriterion'\
                        '/*/ns0:DisplayName'
            ).content
          ).to eq 'Montreuil'
        end
      end

      context 'xml doc payload' do
        let(:doc) do
          subject.add_campaign_criterions(
            campaign_criterions: {
              campaign_criterion: { location_criterion: 'Montreuil' }
            }
          ).envelope.doc
        end

        describe 'header' do
          let(:doc_header) { doc.at_xpath('/soap:Envelope/soap:Header') }

          it do
            expect(
              doc_header.at_xpath('ns0:AuthenticationToken').content
            ).to eq 'yes/we/can'
          end

          it do
            expect(
              doc_header.at_xpath('ns0:CustomerAccountId').content
            ).to eq '666'
          end

          it do
            expect(
              doc_header.at_xpath('ns0:CustomerId').content
            ).to eq '777'
          end

          it do
            expect(
              doc_header.at_xpath('ns0:DeveloperToken').content
            ).to eq '123abc'
          end
        end

        describe 'body' do
          let(:doc_body) do
            doc.at_xpath('/soap:Envelope'\
                            '/soap:Body'\
                              '/ns0:AddCampaignCriterionsRequest'\
                                '/ns0:CampaignCriterions'\
                                  '/ns0:CampaignCriterion')
          end

          describe 'abtract class' do
            let(:criterion) { doc_body.at_xpath('ns0:Criterion') }

            it { expect(criterion.content).to eq 'Montreuil' }

            it do
              expect(
                criterion.attribute('type').namespace.href
              ).to eq doc.namespaces['xmlns:xsi']
            end

            it do
              expect(
                criterion.attribute('type').value
              ).to eq 'ns0:LocationCriterion'
            end
          end
        end
      end
    end
  end
end
