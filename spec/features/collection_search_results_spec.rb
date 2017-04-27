# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Collection Search Results', type: :feature do
  describe 'count' do
    it 'is not active when collection search is not activated' do
      visit search_catalog_path q: 'a brief', search_field: 'all_fields'
      within '#main-container' do
        expect(page).not_to have_css '.al-collection-count'
      end
    end
    it 'is active when collection search is activated' do
      visit search_catalog_path f: { level_sim: ['Collection'] }, search_field: 'all_fields'
      within '#main-container' do
        expect(page).to have_css '.al-collection-count', text: '2 collections'
      end
    end
  end
end
