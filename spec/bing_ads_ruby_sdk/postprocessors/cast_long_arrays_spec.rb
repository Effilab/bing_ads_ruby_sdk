# frozen_string_literal: true

RSpec.describe BingAdsRubySdk::Postprocessors::CastLongArrays do

  def action(params)
    described_class.new(params).call
  end

  it "casts and simplifies long arrays" do
    expect(action({
      long: "foo",
      bar_bar: {
        long: ['1', '2']
      },
      foos: [
        {
          bar: {
            long: ['3', '4']
          }
        }
      ]
    })).to eq({
      long: "foo",
      bar_bar: [1, 2],
      foos: [
        { bar: [3, 4] }
      ]
    })
  end
end