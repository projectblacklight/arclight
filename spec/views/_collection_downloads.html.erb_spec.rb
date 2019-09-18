# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'catalog/_collection_downloads', type: :view do
  let(:document) { SolrDocument.new(id: 'abc123') }

  context 'when on collection show page' do
    let(:pdf_data) { { 'href' => 'http://example.com/documents/abc123.pdf', 'size' => 123 } }
    let(:ead_data) { { 'href' => 'http://example.com/documents/abc123.xml', 'size' => 456 } }
    let(:downloads) do
      instance_double(
        'Arclight::DownloadDownloads',
        files: [
          Arclight::DownloadDownloads::File.new(type: 'pdf', data: pdf_data, document: document),
          Arclight::DownloadDownloads::File.new(type: 'ead', data: ead_data, document: document)
        ]
      )
    end

    before do
      allow(view).to receive(:collection_downloads).and_return(downloads)
      render
    end

    context 'with downloads' do
      it 'shows the menu items' do
        expect(rendered).to have_css('.dropdown')
        expect(rendered).to have_css('button', text: 'Download')
        expect(rendered).to have_css('a', text: 'Collection PDF (123)')
        expect(rendered).to have_css('a[@href="http://example.com/documents/abc123.pdf"]')
        expect(rendered).to have_css('a', text: 'Collection EAD (456)')
        expect(rendered).to have_css('a[@href="http://example.com/documents/abc123.xml"]')
      end
    end

    context 'with no downloads' do
      let(:downloads) do
        instance_double('Arclight::DownloadDownloads', files: [])
      end

      it 'omits the dropdown' do
        expect(rendered).not_to have_css '.dropdown'
      end
    end
  end
end
