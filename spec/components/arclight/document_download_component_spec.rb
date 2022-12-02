# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::DocumentDownloadComponent, type: :component do
  subject(:component) { described_class.new(downloads: downloads) }

  before do
    render_inline(component)
  end

  let(:downloads) { instance_double(Arclight::DocumentDownloads, files: files) }
  let(:pdf_data) { { 'href' => 'http://example.com/documents/abc123.pdf' } }
  let(:pdf) { Arclight::DocumentDownloads::File.new(type: 'pdf', data: pdf_data, document: document) }
  let(:document) { SolrDocument.new(id: 'abc123') }

  context 'with no files' do
    let(:files) { [] }

    it 'renders nothing' do
      expect(page).not_to have_css('*')
    end
  end

  context 'with one file' do
    let(:files) { [pdf] }

    it 'renders a download link' do
      expect(page).to have_link 'Download finding aid', href: 'http://example.com/documents/abc123.pdf'
    end
  end

  context 'with multiple files' do
    let(:files) { [pdf, ead] }
    let(:ead_data) { { 'href' => 'http://example.com/documents/abc123.xml' } }
    let(:ead) { Arclight::DocumentDownloads::File.new(type: 'ead', data: ead_data, document: document) }

    it 'renders download links' do
      expect(page).to have_button 'Download'
      expect(page).to have_link 'Finding aid', href: 'http://example.com/documents/abc123.pdf'
      expect(page).to have_link 'EAD', href: 'http://example.com/documents/abc123.xml'
    end
  end
end
