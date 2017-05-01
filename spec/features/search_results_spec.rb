# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Search resutls', type: :feature do
  describe 'search results' do
    it 'text search works' do
      visit search_catalog_path q: 'a brief', search_field: 'all_fields'
      expect(page).to have_css '.index_title', text: /A brief account/
    end
    it 'renders the expected metadata for a collection' do
      visit search_catalog_path q: '', search_field: 'all_fields'

      within('.document.document-position-0') do
        within('.al-document-title-bar') do
          expect(page).to have_content '1118 Badger Vine Special Collections: MS C 271'
        end

        expect(page).to have_css('h3 a', text: 'Alpha Omega Alpha Archives, 1894-1992')

        expect(page).to have_css('.al-document-creator', text: 'Alpha Omega Alpha')
        expect(page).to have_css('.al-document-extent', text: /^15\.0 linear feet/)
        expect(page).to have_css(
          '.al-document-abstract-or-scope',
          text: /^Alpha Omega Alpha Honor Medical Society was founded in 1902/
        )
      end
    end

    it 'renders the online content label when there is online content' do
      visit search_catalog_path f: { level_sim: ['Collection'] }, search_field: 'all_fields'

      within '.document.document-position-0' do
        expect(page).to have_css('.badge.badge-success', text: 'online content')
      end

      within '.document.document-position-1' do
        expect(page).not_to have_css('.badge.badge-success', text: 'online content')
      end
    end

    it 'does not include result numbers in the document header' do
      visit search_catalog_path q: '', search_field: 'all_fields'

      expect(page).not_to have_css('.document-counter')
    end

    # Very little metadata exists at the component level to drive any tests
    it 'renders metadata to meet minumum DACS requirements for a component'

    it 'renders facets', js: true do
      visit search_catalog_path q: '', search_field: 'all_fields'

      within('#facets') do
        within('.blacklight-collection_sim') do
          expect(page).to have_css('h3 a', text: 'Collection')
          expect(page).to have_css('li .facet-label', text: 'Alpha Omega Alpha Archives', visible: false)
        end

        within('.blacklight-level_sim') do
          expect(page).to have_css('h3 a', text: 'Level')
          expect(page).to have_css('li .facet-label', text: 'Series', visible: false) # level != "otherlevel"
          expect(page).to have_css('li .facet-label', text: 'Binder', visible: false) # "otherlevel" with alt value
          expect(page).to have_css('li .facet-label', text: 'Other', visible: false) # "otherlevel" but missing alt val
        end

        within('.blacklight-creator_ssim') do
          expect(page).to have_css('h3 a', text: 'Creator')
          expect(page).to have_css('li .facet-label', text: 'Alpha Omega Alpha', visible: false)
        end

        within('.blacklight-date_range_sim') do
          expect(page).to have_css('h3 a', text: 'Date range')
          click_link 'Date range'
          expect(page).to have_css('.range_limit', visible: true)
          expect(page).to have_css('.profile canvas.flot-base', visible: true)
        end

        within('.blacklight-names_sim') do
          expect(page).to have_css('h3 a', text: 'Names')
          expect(page).to have_css('li .facet-label', text: 'Root, William Webster, 1867-1932', visible: false)
        end

        within('.blacklight-repository_sim') do
          expect(page).to have_css('h3 a', text: 'Repository')
          expect(page).to have_css('li .facet-label', text: '1118 Badger Vine Special Collections', visible: false)
        end

        within('.blacklight-geogname_sim') do
          expect(page).to have_css('h3 a', text: 'Place')
          expect(page).to have_css('li .facet-label', text: 'Mindanao Island (Philippines)', visible: false)
        end

        within('.blacklight-all_subjects_ssim') do
          expect(page).to have_css('h3 a', text: 'All Subjects')
          expect(page).to have_css('li .facet-label', text: 'Societies', visible: false)
          expect(page).to have_css('li .facet-label', text: 'Fraternizing', visible: false)
          expect(page).to have_css('li .facet-label', text: 'Photographs', visible: false)
          expect(page).to have_css('li .facet-label', text: 'Medicine', visible: false)
        end
      end
    end
  end
end
