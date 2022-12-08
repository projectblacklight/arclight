# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Search Breadcrumb' do
  context 'on regular search results' do
    it do
      visit search_catalog_path q: 'a brief', search_field: 'all_fields'
      within '.al-search-breadcrumb' do
        expect(page).to have_link 'Home'
        expect(page).to have_content 'Search results'
      end
    end

    it do
      visit search_catalog_path f: { level: ['Collection'] }, search_field: 'all_fields'
      within '.al-search-breadcrumb' do
        expect(page).to have_link 'Home'
        expect(page).to have_content 'Collections'
      end
    end
  end
end
