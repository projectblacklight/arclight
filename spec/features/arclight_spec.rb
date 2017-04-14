# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Arclight', type: :feature do
  it 'navigates to homepage' do
    visit '/'
    expect(page).to have_css 'h2', text: 'Welcome!'
  end
  it 'an index view is present with search results' do
    visit search_catalog_path q: '', search_field: 'all_fields'
    expect(page).to have_css '.document', count: 10
  end

  describe 'search results' do
    it 'renders metadata to meet minumum DACS requirements' do
      visit search_catalog_path q: '', search_field: 'all_fields'

      expect(page).to have_css('h3 a', text: 'Alpha Omega Alpha Archives')

      expect(page).to have_css('dt', text: 'Unit ID')
      expect(page).to have_css('dd', text: 'MS C 271')

      expect(page).to have_css('dt', text: 'Repository')
      expect(page).to have_css('dd', text: '1118 Badger Vine Special Collections')

      # This is actually finding the date in the 2nd result on the page,
      # not the first like the rest of the metadata in this test
      expect(page).to have_css('dt', text: 'Date')
      expect(page).to have_css('dd', text: '1902-1976')

      expect(page).to have_css('dt', text: 'Language')
      expect(page).to have_css('dd', text: /English/)

      # expect(page).to have_css('dt', text: 'Phyiscal Description')
      # expect(page).to have_css('dd', text: '?')

      # expect(page).to have_css('dt', text: 'Scope Content')
      # expect(page).to have_css('dd', text: '?')

      # expect(page).to have_css('dt', text: 'Conditions Governing Access')
      # expect(page).to have_css('dd', text: '?')

      expect(page).to have_css('dt', text: 'Creator')
      expect(page).to have_css('dd', text: 'Alpha Omega Alpha')
    end
  end

  describe 'show page' do
    it 'renders metadata to meet minumum DACS requirements' do
      visit solr_document_path(id: 'aoa271')

      expect(page).to have_css('h1', text: 'Alpha Omega Alpha Archives')

      expect(page).to have_css('dt', text: 'Unit ID')
      expect(page).to have_css('dd', text: 'MS C 271')

      expect(page).to have_css('dt', text: 'Repository')
      expect(page).to have_css('dd', text: '1118 Badger Vine Special Collections')

      # Currently this indexing code does not index a date at the collection level
      # expect(page).to have_css('dt', text: 'Date')
      # expect(page).to have_css('dd', text: '1902-1976')

      expect(page).to have_css('dt', text: 'Language')
      expect(page).to have_css('dd', text: /English/)

      # expect(page).to have_css('dt', text: 'Phyiscal Description')
      # expect(page).to have_css('dd', text: '?')

      # expect(page).to have_css('dt', text: 'Scope Content')
      # expect(page).to have_css('dd', text: '?')

      # expect(page).to have_css('dt', text: 'Conditions Governing Access')
      # expect(page).to have_css('dd', text: '?')

      expect(page).to have_css('dt', text: 'Creator')
      expect(page).to have_css('dd', text: 'Alpha Omega Alpha')
    end
  end
end
