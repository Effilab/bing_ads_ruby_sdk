# frozen_string_literal: true

RSpec.describe BingAdsRubySdk::Postprocessors::Snakize do
  def action(params)
    described_class.new(params).call
  end

  it "changes keys to snake version" do
    expect(action({
      "Foo" => "foo",
      "BarBar" => {
        "BazBaz" => "baz"
      },
      "Coucou" => [
        {
          "Bisou" => 1
        }
      ]
    })).to eq({
      foo: "foo",
      bar_bar: {
        baz_baz: "baz"
      },
      coucou: [
        {
          bisou: 1
        }
      ]
    })
  end

  it "handles properly 'long' tag name" do
    expect(action({
      "long" => "1"
    })).to eq({
      long: "1"
    })
  end
end
