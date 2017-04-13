# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Arclight', type: :feature do
  it 'an index view is present with search results' do
    visit search_catalog_path q: '', search_field: 'all_fields'
    expect(page).to have_css '.document', count: 10
  end

  describe 'search results' do
    it 'renders metadata to meet minumum DACS requirements for a collection' do
      visit search_catalog_path q: '', search_field: 'all_fields'

      # TODO: need to inspect the first hit only

      expect(page).to have_css('h3 a', text: 'Alpha Omega Alpha Archives')

      expect(page).to have_css('dt', text: 'Collection Title')
      expect(page).to have_css('dd', text: 'Alpha Omega Alpha Archives')

      expect(page).to have_css('dt', text: 'Unit ID')
      expect(page).to have_css('dd', text: 'MS C 271')

      expect(page).to have_css('dt', text: 'Repository')
      expect(page).to have_css('dd', text: '1118 Badger Vine Special Collections')

      expect(page).to have_css('dt', text: 'Date')
      expect(page).to have_css('dd', text: '1894-1992')

      expect(page).to have_css('dt', text: 'Language')
      expect(page).to have_css('dd', text: /English/)

      expect(page).to have_css('dt', text: 'Physical Description')
      expect(page).to have_css('dd', text: /linear feet/)

      expect(page).to have_css('dt', text: 'Scope Content')
      expect(page).to have_css('dd', text: /Correspondence/)

      expect(page).to have_css('dt', text: 'Conditions Governing Access')
      expect(page).to have_css('dd', text: /No restrictions on access/)

      expect(page).to have_css('dt', text: 'Creator')
      expect(page).to have_css('dd', text: 'Alpha Omega Alpha')
    end

    it 'renders metadata to meet minumum DACS requirements for a component'

    it 'renders facets' do
      visit search_catalog_path q: '', search_field: 'all_fields'

      within('#facets') do
        expect(page).to have_css('h3 a', text: 'Level')
      end
    end
  end

  describe 'show page' do
    it 'renders metadata to meet minumum DACS requirements for a collection' do
      visit solr_document_path(id: 'aoa271')

      expect(page).to have_css('h1', text: 'Alpha Omega Alpha Archives')

      expect(page).to have_css('dt', text: 'Collection Title')
      expect(page).to have_css('dd', text: 'Alpha Omega Alpha Archives')

      expect(page).to have_css('dt', text: 'Unit ID')
      expect(page).to have_css('dd', text: 'MS C 271')

      expect(page).to have_css('dt', text: 'Repository')
      expect(page).to have_css('dd', text: '1118 Badger Vine Special Collections')

      expect(page).to have_css('dt', text: 'Date')
      expect(page).to have_css('dd', text: '1894-1992')

      expect(page).to have_css('dt', text: 'Language')
      expect(page).to have_css('dd', text: /English/)

      expect(page).to have_css('dt', text: 'Physical Description')
      expect(page).to have_css('dd', text: /linear feet/)

      expect(page).to have_css('dt', text: 'Scope Content')
      expect(page).to have_css('dd', text: /Correspondence/)

      expect(page).to have_css('dt', text: 'Conditions Governing Access')
      expect(page).to have_css('dd', text: /No restrictions on access/)

      expect(page).to have_css('dt', text: 'Creator')
      expect(page).to have_css('dd', text: 'Alpha Omega Alpha')
    end

    it 'renders metadata to meet minumum DACS requirements for a component'
  end
end
