RSpec.describe BingAdsRubySdk::HttpClient do
  describe ".post" do
    let(:request) do
      double(:request,
        url: "http://bing_url.com/foo",
        content: "body",
        headers: "headers")
    end
    let(:excon) { double(:excon) }
    let(:response) { double(:response, body: "soap xml") }

    before do
      expect(::Excon).to receive(:new).once.and_return(excon)
      expect(excon).to receive(:post).at_least(1).times.with(
        path: "/foo",
        body: "body",
        headers: "headers"
      ).and_return(response)
    end

    context "successful request" do
      it "returns response's body" do
        expect(described_class.post(request)).to eq("soap xml")
      end
    end

    context "on subsequent requests" do
      it "pools the existing connection" do
        expect(described_class.post(request)).to eq("soap xml")

        expect(::Excon).not_to receive(:new)
        expect(described_class.post(request)).to eq("soap xml")
      end
    end
  end

  describe ".close_http_connections" do
    let(:connection1) { double("connection1") }
    let(:connection2) { double("connection2") }
    it "closes existing connections" do
      expect(described_class).to receive(:http_connections).and_return({
        "url1" => connection1,
        "url2" => connection2
      })
      expect(connection1).to receive :reset
      expect(connection2).to receive :reset

      described_class.close_http_connections
    end
  end
end
