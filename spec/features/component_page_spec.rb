# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Component Page', type: :feature do
  let(:doc_id) { 'aoa271aspace_843e8f9f22bac69872d0802d6fffbb04' }

  before { visit solr_document_path(id: doc_id) }

  describe 'Component section heading' do
    it 'includes the level' do
      expect(page).to have_css('h3.al-show-sub-heading', text: 'About this file')
    end
  end

  describe 'label/title' do
    it 'does not double escape entities in the heading' do
      expect(page).to have_css('h1', text: /^"A brief account of the origin of/)
      expect(page).not_to have_css('h1', text: /^&quot;A brief account of the origin of/)
    end
  end

  describe 'sidebar' do
    it 'includes an online section when the component includes a DAO' do
      within('.al-sticky-sidebar') do
        expect(page).to have_css('h3', text: 'Online')
        # Blacklight renders the dt and it is not necessary in our display
        expect(page).to have_css('dt', visible: false)

        expect(page).to have_css('.al-digital-object', count: 2)

        expect(page).to have_css('.al-digtal-object-label', text: 'Folder of digitized stuff')
        expect(page).to have_css('.al-digtal-object-label', text: /^Letter from Christian B\. Anfinsen/)
        expect(page).to have_css('.btn-primary', text: 'Open viewer', count: 2)
      end
    end

    describe 'context_sidebar' do
      context 'that has a visitation note' do
        it 'has an in person card' do
          within '#accordion' do
            expect(page).to have_css '.card-header h3', text: 'In person'
            expect(page).to have_css '.card-block dt', text: 'Location of this collection:'
            expect(page).to have_css '.card-block dd .al-repository-contact-building', text: 'Building 38, Room 1E-21'
          end
        end
      end
    end
  end

  describe 'collection context', js: true do
    it 'has a collection title' do
      within '#collection-context' do
        expect(page).to have_css 'h1', text: 'Alpha Omega Alpha Archives, 1894-1992'
      end
    end
    it 'has a ancestor list, siblings and highlighted self' do
      within '#collection-context' do
        expect(page).to have_css(
          '.al-hierarchy-level-0 article a',
          text: 'Series I: Administrative Records, 1902-1976'
        )
        within '.al-contents' do
          expect(page).to have_css(
            '.al-hierarchy-highlight h3',
            text: /"A brief account of the origin/
          )
          expect(page).to have_css 'article', text: 'Statements of purpose, c.1902'
          expect(page).to have_css 'article', text: 'Constitution - notes on drafting of constitution, c.1902-1903'
          click_link('Statements of purpose, c.1902')
        end
      end
      expect(page).to have_css 'h1', text: 'Statements of purpose, c.1902'
      within '#collection-context .al-contents' do
        expect(page).to have_css '.al-hierarchy-highlight h3', text: 'Statements of purpose, c.1902'
        expect(page).to have_css 'article', text: /"A brief account of the origin/
        expect(page).to have_css(
          'article',
          text: 'Constitution - notes on drafting of constitution, c.1902-1903'
        )
        click_link 'Constitution - notes on drafting of constitution, c.1902-1903'
      end
      expect(page).to have_css 'h1', text: 'Constitution - notes on drafting of constitution, c.1902-1903'
      within '#collection-context .al-contents' do
        expect(page).to have_css(
          '.al-hierarchy-highlight h3',
          text: 'Constitution - notes on drafting of constitution, c.1902-1903'
        )
        expect(page).to have_css 'article', text: 'Statements of purpose, c.1902'
        expect(page).to have_css 'article', text: 'Constitution and by-laws - drafts, 1902-1904'
      end
    end
  end
end
