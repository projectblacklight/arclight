# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Field-based search results', type: :feature do
  describe 'searches by' do
    it '#all_fields' do
      visit search_catalog_path q: 'a brief account', search_field: 'all_fields'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /A brief account/
      end
    end

    it '#keyword' do
      visit search_catalog_path q: 'a brief account', search_field: 'keyword'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /A brief account/
      end
    end

    it '#name' do
      visit search_catalog_path q: 'root', search_field: 'name'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#place' do
      visit search_catalog_path q: 'island', search_field: 'place'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#subject' do
      visit search_catalog_path q: 'medicine', search_field: 'subject'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#title' do
      visit search_catalog_path q: 'motto', search_field: 'title'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /Plans for motto/
      end
      within('.document-position-1') do
        expect(page).to have_css '.index_title', text: /Dr. Root and L. Raymond Higgins/
      end
    end
  end
end
