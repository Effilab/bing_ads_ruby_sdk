# frozen_string_literal: true

RSpec.describe BingAdsRubySdk::OAuth2::FsStore do
  after do
    File.unlink('./.abc') if File.file?('./.abc')
  end
  let(:store) { described_class.new('.abc') }

  context 'when not empty' do
    before { store.write(a: 1, b: '2') }
    it 'writes and read properly' do
      expect(store.read).to eq('a' => 1, 'b' => '2')
    end
  end

  context 'when empty' do
    it 'reads properly' do
      expect(store.read).to be nil
    end
  end
end
