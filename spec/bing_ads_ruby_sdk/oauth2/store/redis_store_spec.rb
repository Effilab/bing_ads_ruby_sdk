
module BingAdsRubySdk
  module OAuth2
    module Store
      RSpec.describe RedisStore do
        subject do
          described_class.new('abc')
        end

        before do
          mock_redis = MockRedis.new
          BingAdsRubySdk::OAuth2::Store::RedisStore.redis = mock_redis
        end

        it { expect(subject).to be_instance_of(RedisStore) }
        it { expect(subject.token_key).to eq('abc') }

        describe "#write" do
          it { expect(subject.write(a: 1, b: "2")).to be(true) }
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
end
