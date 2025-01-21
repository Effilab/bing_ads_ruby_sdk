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
    let(:http_connections) { {} }

    before do
      allow(described_class).to receive(:http_connections).and_return(http_connections)
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
      it "pools the existing connection using the scheme and host" do
        expect(described_class.post(request)).to eq("soap xml")
        expect(described_class.post(request)).to eq("soap xml")
        expect(http_connections).to include("http://bing_url.com" => excon)
      end
    end
  end

  describe ".close_http_connections" do
    let(:connection1) { double("connection1") }
    let(:connection2) { double("connection2") }
    let(:connections) do
      {
        "url1" => connection1,
        "url2" => connection2
      }
    end
    it "closes existing connections" do
      expect(described_class).to receive(:http_connections).twice.and_return(connections)
      expect(connection1).to receive :reset
      expect(connection2).to receive :reset

      described_class.close_http_connections

      expect(connections).to be_empty
    end
  end
end
