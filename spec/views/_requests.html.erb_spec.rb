# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'arclight/_requests', type: :view do
  let(:document) { SolrDocument.new(id: 'abc123') }
  let(:config) { instance_double(Arclight::Repository) }
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    allow(document).to receive(:repository_config).and_return(config)
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:action_name).and_return('show')
    allow(view).to receive(:document).and_return(document)
    allow(view).to receive(:item_requestable?).and_return(true)
  end

  context 'with EAD documents which require Aeon requests' do
    let(:document_downloads) { instance_double(Arclight::DocumentDownloads::File) }

    before do
      allow(document_downloads).to receive(:href).and_return('https://sample.request.com')
      allow(document).to receive(:ead_file).and_return(document_downloads)
      allow(config).to receive(:available_request_types).and_return([:aeon_web_ead])
      allow(config).to receive(:request_config_for_type).and_return({ 'request_url' => 'https://sample.request.com',
                                                                      'request_mappings' => 'Action=10&Form=31&Value=ead_url' })

      render
    end

    it 'renders links to the Aeon request form' do
      expect(rendered).to have_css '.al-show-actions-box-request'
      expect(rendered).to have_css '.al-show-actions-box-request a[href^="https://sample.request.com"]'
    end
  end

  context 'with EAD documents which require external Aeon requests' do
    let(:config_hash) do
      {
        'request_url' => 'https://example.com/aeon/aeon.dll',
        'request_mappings' => {
          'url_params' => {
            'Action' => 11,
            'Type' => 200
          },
          'static' => {
            'SystemId' => 'ArcLight',
            'ItemInfo1' => 'manuscript'
          },
          'accessor' => {
            'ItemTitle' => 'collection_name'
          }
        }
      }
    end

    before do
      allow(config).to receive(:available_request_types).and_return([:aeon_external_request_endpoint])
      allow(config).to receive(:request_config_for_type).and_return(config_hash)
      render
    end

    it 'renders links to the external Aeon request endpoint' do
      expect(rendered).to have_css '.al-request-form'
      expect(rendered).to have_css '.al-request-form[action^="https://example.com/aeon/aeon.dll"]'
    end
  end
end
