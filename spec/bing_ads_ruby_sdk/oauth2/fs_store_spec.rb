require 'spec_helper'

module BingAdsRubySdk
  module OAuth2
    RSpec.describe FsStore do
      after do
        File.unlink('./.abc') if File.file?('./.abc')
      end

      subject do
        described_class.new('abc')
      end

      it { expect(subject).to be_instance_of(FsStore) }
      it { expect(subject.token_key).to eq('abc') }

      describe "#write" do
        it { expect(subject.write(a: 1, b: "2")).to be_instance_of(File) }
      end

      describe "#read" do
        context "when not empty" do
          before { subject.write(a: 1, b: "2") }
          it { expect(subject.read).to eq("a" => 1, "b" => "2") }
        end

        context "when empty" do
          it { expect(subject.read).to be nil }
        end
      end
    end
  end
end
