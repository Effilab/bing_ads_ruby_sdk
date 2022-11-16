# frozen_string_literal: true

RSpec.describe BingAdsRubySdk::Preprocessors::Camelize do
  def action(params)
    described_class.new(params).call
  end

  it 'changes keys to camelize version' do
    expect(action({
                    foo: 'foo',
                    bar_bar: {
                      baz_baz: 'baz'
                    },
                    coucou: [
                      {
                        bisou: 1
                      }
                    ]
                  })).to eq({
                              'Foo' => 'foo',
                              'BarBar' => {
                                'BazBaz' => 'baz'
                              },
                              'Coucou' => [
                                {
                                  'Bisou' => 1
                                }
                              ]
                            })
  end

  it "doesnt camelize 'long' tag name" do
    expect(action({
                    long: '1'
                  })).to eq({
                              'long' => '1'
                            })
  end
end
