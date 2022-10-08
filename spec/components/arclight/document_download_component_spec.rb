# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::DocumentDownloadComponent, type: :component do
  let(:render) do
    component.render_in(controller.view_context)
  end

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:attr) { {} }
  let(:component) { described_class.new(file: file, **attr) }

  let(:pdf_data) { { 'href' => 'http://example.com/documents/abc123.pdf', 'size' => 123 } }
  let(:file) { Arclight::DocumentDownloads::File.new(type: 'pdf', data: pdf_data, document: document) }
  let(:document) { SolrDocument.new(id: 'abc123') }

  it 'renders a download link' do
    expect(rendered).to have_link 'Download finding aid (123)', href: 'http://example.com/documents/abc123.pdf'
  end
end
