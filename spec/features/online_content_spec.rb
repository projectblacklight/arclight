# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Online Content', type: :feature do
  let(:doc_id) { 'aoa271aspace_843e8f9f22bac69872d0802d6fffbb04' }

  before { visit solr_document_path(id: doc_id) }

  describe 'Viewer' do
    context 'embedded content' do
      let(:doc_id) { 'a0011-xmlaspace_ref6_lx4' }

      it 'renders digital object viewer initialization markup', js: true do
        expect(page).to have_css(
          '.al-oembed-viewer[data-arclight-oembed-url="http://purl.stanford.edu/kc844kt2526"]',
          visible: false
        )
        click_link('Online content')
        expect(page).to have_css(
          '.al-oembed-viewer[data-arclight-oembed-url="http://purl.stanford.edu/kc844kt2526"]',
          visible: true
        )
      end
    end

    context 'non-embeddable content' do
      let(:doc_id) { 'aoa271aspace_843e8f9f22bac69872d0802d6fffbb04' }

      it 'renders a list of links', js: true do
        click_link('Online content')
        expect(page).to have_link('Folder of digitized stuff')
        expect(page).to have_css('a', text: /^Letter from Christian B. Anfinsen/)
      end
    end

    context 'a collection w/o digital objects at the collection level' do
      let(:doc_id) { 'a0011-xml' }

      it 'renders a flat list of the child components with online content', js: true do
        click_link('Online content')

        within('.documents-online_contents') do
          expect(page).to have_css('article', count: 1)

          expect(page).to have_css('.document-title-heading', text: 'Box 1: Photograph Album')
        end
      end
    end

    context 'no content' do
      let(:doc_id) { 'aoa271aspace_a951375d104030369a993ff943f61a77' }

      it 'renders disabled tab' do
        expect(page).to have_css('.nav-link.disabled', text: 'No online content')
      end
    end
  end
end
