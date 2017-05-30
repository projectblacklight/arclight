# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'catalog/_collection_downloads', type: :view do
  context 'when on collection show page' do
    let(:pdf_data) { { href: '/documents/abc123.pdf', size: 123 } }
    let(:ead_data) { { href: '/documents/abc123.xml', size: 456 } }
    let(:downloads) { { pdf: pdf_data, ead: ead_data } }

    before do
      allow(view).to receive(:downloads).and_return(downloads)
      render
    end

    context 'with both downloads' do
      it 'shows the menu items' do
        expect(rendered).to have_css('.dropdown')
        expect(rendered).to have_css('button', text: 'Download')
        expect(rendered).to have_css('a', text: 'Collection PDF (123)')
        expect(rendered).to have_css('a[@href="/documents/abc123.pdf"]')
        expect(rendered).to have_css('a', text: 'Collection EAD (456)')
        expect(rendered).to have_css('a[@href="/documents/abc123.xml"]')
      end
    end
    context 'with PDF download' do
      let(:ead_data) { {} }

      it 'shows the menu item' do
        expect(rendered).to have_css('.dropdown')
        expect(rendered).to have_css('a', text: 'Collection PDF (123)')
        expect(rendered).not_to have_css('a', text: 'Collection EAD (456)')
      end
    end
    context 'with EAD download' do
      let(:pdf_data) { {} }

      it 'shows the menu item' do
        expect(rendered).to have_css('.dropdown')
        expect(rendered).not_to have_css('a', text: 'Collection PDF (123)')
        expect(rendered).to have_css('a', text: 'Collection EAD (456)')
      end
    end
    context 'with no downloads' do
      let(:pdf_data) { {} }
      let(:ead_data) { {} }

      it 'omits the dropdown' do
        expect(rendered).not_to have_css '.dropdown'
      end
    end
  end
end
