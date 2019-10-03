# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'catalog/_document_downloads', type: :view do
  let(:document) { SolrDocument.new(id: 'abc123') }

  context 'when on collection show page' do
    let(:pdf_data) { { 'href' => 'http://example.com/documents/abc123.pdf', 'size' => 123 } }
    let(:ead_data) { { 'href' => 'http://example.com/documents/abc123.xml', 'size' => 456 } }
    let(:downloads) do
      instance_double(
        'Arclight::DocumentDownloads',
        files: [
          Arclight::DocumentDownloads::File.new(type: 'pdf', data: pdf_data, document: document),
          Arclight::DocumentDownloads::File.new(type: 'ead', data: ead_data, document: document)
        ]
      )
    end

    before do
      allow(view).to receive(:document_downloads).and_return(downloads)
      render
    end

    context 'with downloads' do
      it 'shows the menu items' do
        expect(rendered).to have_css('.al-show-actions-box-downloads')
        expect(rendered).to have_css('a', text: 'Download finding aid (123)')
        expect(rendered).to have_css('a[@href="http://example.com/documents/abc123.pdf"]')
        expect(rendered).to have_css('a', text: 'Download EAD (456)')
        expect(rendered).to have_css('a[@href="http://example.com/documents/abc123.xml"]')
      end
    end

    context 'with no downloads' do
      let(:downloads) do
        instance_double('Arclight::DocumentDownloads', files: [])
      end

      it 'omits the dropdown' do
        expect(rendered).not_to have_css '.dropdown'
      end
    end
  end

  describe 'ActionView::PartialRenderer#render' do
    subject(:downloads) { Arclight::DocumentDownloads.new(document) }

    it 'generates markup using the _document_downloads view partial' do
      expect(render(downloads)).to eq rendered
    end
  end
end
