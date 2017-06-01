# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Component Page', type: :feature do
  let(:doc_id) { 'aoa271aspace_843e8f9f22bac69872d0802d6fffbb04' }

  before { visit solr_document_path(id: doc_id) }

  describe 'tabbed display' do
    it 'clicking contents toggles visibility', js: true do
      expect(page).to have_css '#overview', visible: true
      expect(page).to have_css '#online-content', visible: false
      click_link 'Online content'
      expect(page).to have_css '#overview', visible: false
      expect(page).to have_css '#online-content', visible: true
    end
  end

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

  describe 'metadata' do
    let(:doc_id) { 'aoa271aspace_dc2aaf83625280ae2e193beb3f4aea78' }

    it 'uses our rules for displaying containers' do
      expect(page).to have_css('dd', text: 'Box 1, Folder 4-5')
    end
  end

  describe 'sidebar' do
    describe 'context_sidebar' do
      context 'that has restrictions and terms of access' do
        it 'has a terms and conditions card' do
          within '#accordion' do
            expect(page).to have_css('.card-header h3', text: 'Terms & Conditions')
            expect(page).to have_css('.card-block dt', text: 'Restrictions:')
            expect(page).to have_css('.card-block dd', text: 'No restrictions on access.')
            expect(page).to have_css('.card-block dt', text: 'Terms of Access:')
            expect(page).to have_css('.card-block dd', text: /^Copyright was transferred to the public domain./)
          end
        end
      end
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
    it 'has a linkable collection title' do
      within '#collection-context' do
        expect(page).to have_css 'a[href="/catalog/aoa271"]', text: 'Alpha Omega Alpha Archives, 1894-1992'
        expect(page).to have_css 'h1'
      end
    end
    it 'has ancestor component with badge having children count' do
      within '#collection-context' do
        within '.al-hierarchy-level-0' do
          expect(page).to have_css(
            'article a',
            text: 'Series I: Administrative Records, 1902-1976'
          )
          expect(page).to have_css('.al-number-of-children-badge', text: '25 children')
          expect(page).not_to have_css('.al-number-of-children-badge', text: /View/)
        end
      end
    end
    it 'has siblings and highlighted self' do
      within '#collection-context' do
        within '.al-contents' do
          expect(page).to have_css(
            '.al-hierarchy-highlight h3',
            text: /"A brief account of the origin/
          )
          expect(page).to have_css 'article', text: 'Statements of purpose, c.1902'
          expect(page).to have_css 'article', text: 'Constitution - notes on drafting of constitution, c.1902-1903'
        end
      end
    end
    it 'supports clicks within collection context' do
      within '#collection-context' do
        within '.al-contents' do
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
    it 'ancestor list does not contain cousins' do
      visit solr_document_path 'aoa271aspace_e8755922a9336970292ca817983e7139'
      within '#collection-context .al-contents.al-hierarchy-level-4' do
        expect(page).to have_css 'h3', count: 1
      end
    end
  end
  describe 'breadcrumb' do
    it 'links home, collection, parents and displays title' do
      within '.al-show-breadcrumb' do
        expect(page).to have_css 'a', text: 'Home'
        expect(page).to have_css 'a', text: 'Collections'
        expect(page).to have_css 'a', count: 4
        expect(page).to have_content(/"A brief account of the origin of the /)
      end
    end
  end
end
