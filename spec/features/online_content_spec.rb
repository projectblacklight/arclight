# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Online Content' do
  let(:doc_id) { 'aoa271aspace_843e8f9f22bac69872d0802d6fffbb04' }

  before { visit solr_document_path(id: doc_id) }

  describe 'Viewer' do
    context 'embedded content' do
      let(:doc_id) { 'a0011-xmlaspace_ref6_lx4' }

      it 'renders digital object viewer initialization markup', js: true do
        expect(page).to have_css(
          '.al-oembed-viewer[data-arclight-oembed-url-value="http://purl.stanford.edu/kc844kt2526"]',
          visible: :all
        )
      end
    end

    context 'non-embeddable content' do
      let(:doc_id) { 'aoa271aspace_843e8f9f22bac69872d0802d6fffbb04' }

      it 'renders a list of links', js: true do
        expect(page).to have_link 'Folder of digitized stuff'
        expect(page).to have_link 'Letter from Christian B. Anfinsen'
      end
    end
  end
end
