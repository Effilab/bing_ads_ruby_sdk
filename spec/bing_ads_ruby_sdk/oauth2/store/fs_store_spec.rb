module BingAdsRubySdk
  module OAuth2
    module Store
      RSpec.describe FsStore do
        after do
          File.unlink('./.abc') if File.file?('./.abc')
        end

        subject do
          described_class.new('abc')
        end

        it { expect(subject).to be_instance_of(FsStore) }
        it { expect(subject.token_key).to eq('abc') }
        it { expect(subject.file_name).to eq('.abc') }

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

        describe ".config" do
          context "when empty" do
            it {
              expect(subject.file_name).to eq('.abc')
              expect(subject.token_key).to eq('abc')
            }
          end

          context "when provided" do
            let(:file_name) { "test.json"}
            it {
              described_class.config = file_name
              expect(subject.file_name).to eq(file_name)
              expect(subject.token_key).to eq('abc')
            }
          end
        end
      end
    end
  end
end
