# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Search results' do
  describe 'search results' do
    it 'text search works' do
      visit search_catalog_path q: 'a brief', search_field: 'all_fields'
      expect(page).to have_css '.index_title', text: /A brief account/
    end

    it 'retains the search query in the search box' do
      visit search_catalog_path q: 'papers', search_field: 'all_fields'
      expect(page).to have_css 'input#q[value="papers"]'
    end

    it 'renders the expected metadata for a collection' do
      visit search_catalog_path q: '', search_field: 'all_fields'

      within('.document.document-position-5') do
        expect(page).to have_css('h3 a', text: 'Alpha Omega Alpha Archives, 1894-1992')
        expect(page).to have_css('.blacklight-icons svg')
        expect(page).to have_css('.al-document-creator', text: 'Alpha Omega Alpha')
        expect(page).to have_css('.documentHeader .al-document-extent', text: /^15\.0 linear feet/)
        expect(page).to have_css(
          '.al-document-abstract-or-scope',
          text: /^Alpha Omega Alpha Honor Medical Society was founded in 1902/
        )
      end
    end

    it 'renders the online content label when there is online content' do
      visit search_catalog_path f: { level: ['Collection'] }, search_field: 'all_fields'

      online_doc = page.all('.document').find do |el|
        el.all(
          'h3.index_title',
          text: 'Alpha Omega Alpha Archives, 1894-1992'
        ).present?
      end

      not_online_doc = page.all('.document').find do |el|
        el.all(
          'h3.index_title',
          text: 'The Italian or the confessional of the black penitents : typescript, 1930'
        ).present?
      end

      within online_doc do
        expect(page).to have_css('.al-online-content-icon')
      end

      within not_online_doc do
        expect(page).to have_no_css('.al-online-content-icon')
      end
    end

    it 'does not include result numbers in the document header' do
      visit search_catalog_path q: '', search_field: 'all_fields'

      expect(page).to have_no_css('.document-counter')
    end

    it 'does not double escape entities in the heading' do
      visit search_catalog_path q: '', search_field: 'all_fields'
      expect(page).to have_css(
        'h3.index_title',
        text: '"A brief account of the origin of the Alpha Omega Alpha Honorary Fraternity" - William W. Root, n.d.'
      )
      expect(page).to have_no_css(
        'h3.index_title',
        text: /&quote;A brief account of the origin/
      )
    end

    # Very little metadata exists at the component level to drive any tests
    it 'renders metadata to meet minumum DACS requirements for a component'

    it 'renders facets', :js do
      visit search_catalog_path q: '', search_field: 'all_fields'

      within('#facets') do
        within('.blacklight-collection') do
          expect(page).to have_css('h3 button', text: 'Collection')
          expect(page).to have_css('li .facet-label', text: 'Alpha Omega Alpha Archives, 1894-1992', visible: :hidden)
        end

        within('.blacklight-level') do
          expect(page).to have_css('h3 button', text: 'Level')
          expect(page).to have_css('li .facet-label', text: 'Series', visible: :hidden) # level != "otherlevel"
          expect(page).to have_css('li .facet-label', text: 'Binder', visible: :hidden) # "otherlevel" with alt value
          expect(page).to have_css('li .facet-label', text: 'Other', visible: :hidden) # "otherlevel" but missing alt val
        end

        within('.blacklight-creators') do
          expect(page).to have_css('h3 button', text: 'Creator')
          expect(page).to have_css('li .facet-label', text: 'Alpha Omega Alpha', visible: :hidden)
          expect(page).to have_css('li .facet-label', text: 'Stanford University', visible: :hidden)
        end

        within('.blacklight-names') do
          expect(page).to have_css('h3 button', text: 'Names')
          expect(page).to have_css('li .facet-label', text: 'Department of Special Collections and University Archives', visible: :hidden)
          expect(page).to have_css('li .facet-label', text: '1118 Badger Vine Special Collections', visible: :hidden)
        end

        within('.blacklight-repository') do
          expect(page).to have_css('h3 button', text: 'Repository')
          expect(page).to have_css('li .facet-label', text: 'National Library of Medicine. History of Medicine Division', visible: :hidden)
        end

        within('.blacklight-places') do
          expect(page).to have_css('h3 button', text: 'Places')
          expect(page).to have_css('li .facet-label', text: 'Mindanao Island (Philippines)', visible: :hidden)
          expect(page).to have_css('li .facet-label', text: 'Yosemite National Park (Calif.)', visible: :hidden)
        end

        within('.blacklight-access_subjects') do
          expect(page).to have_css('h3 button', text: 'Subjects')
          expect(page).to have_css('li .facet-label', text: 'Slides.', visible: :hidden)
          expect(page).to have_css('li .facet-label', text: 'Fraternizing', visible: :hidden)
        end

        within('.blacklight-access') do
          expect(page).to have_css('h3 button', text: 'Access')
          expect(page).to have_css('li .facet-label', text: 'Online access', visible: :hidden)
        end
      end
    end

    it 'renders the repository card when faceted on repository' do
      visit search_catalog_path f: {
        repository: ['National Library of Medicine. History of Medicine Division']
      }, search_field: 'all_fields'

      expect(page).to have_css('.al-repository-card')
      expect(page).to have_css('.al-repository')
      expect(page).to have_no_css('.al-repository-extra')
    end

    it 'does not include repository card if not faceted on repository' do
      visit search_catalog_path q: '', search_field: 'all_fields'

      expect(page).to have_no_css('.al-repository-card')
    end

    it 'does not include repository card if faceted on something that is not repository' do
      visit search_catalog_path f: {
        names: ['Owner of the reel of yellow nylon rope']
      }, search_field: 'all_fields'

      expect(page).to have_no_css('.al-repository-card')
    end
  end

  describe 'sorting' do
    it 'provides a dropdown with all the options' do
      visit search_catalog_path q: '', search_field: 'all_fields'
      within '.sort-dropdown' do
        expect(page).to have_css '.dropdown-item', count: 7
      end
    end
  end
end
