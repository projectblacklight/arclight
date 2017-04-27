# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'catalog/_collection_count', type: :view do
  context 'when on collection search page' do
    before do
      allow(view).to receive(:collection_active?).and_return(true)
    end
    context 'with 0 collections' do
      it do
        allow(view).to receive(:collection_count).and_return(0)
        render
        expect(rendered).to include '0 collections'
      end
    end
    context 'with 1 collection' do
      it do
        allow(view).to receive(:collection_count).and_return(1)
        render
        expect(rendered).to include '1 collection'
      end
    end
    context 'with 100,000 collections' do
      it do
        allow(view).to receive(:collection_count).and_return(100_000)
        render
        expect(rendered).to include '100,000 collections'
      end
    end
  end
  context 'when not on collection search page' do
    it do
      allow(view).to receive(:collection_active?).and_return(false)
      render
      expect(rendered).to be_empty
    end
  end
end
