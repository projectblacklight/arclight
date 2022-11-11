# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Compact Search Results' do
  it 'As a user I should be able to view results in a compact display' do
    visit root_path
    click_button 'Search'

    expect(page).to have_css('.documents-list')
    expect(page).to have_css('h3.index_title', text: 'Alpha Omega Alpha Archives, 1894-1992')

    click_link 'Compact'

    expect(page).not_to have_css('.documents-list')
    expect(page).to have_css('.documents-compact')
    expect(page).to have_css('article.document', count: 10)
    within '.document-position-3' do
      # Has breadcrumbs
      expect(page).to have_css '.breadcrumb-links a', text: /National Library of/
      # Has Containers
      expect(page).to have_css '.al-document-container', text: 'Box 1, Folder 1'
      # Has Online Content Indicator
      expect(page).to have_css '.al-online-content-icon'
      # Has Bookmark Control
      expect(page).to have_css 'form.bookmark-toggle'
    end
  end

  it 'Shows highlights in compact view' do
    visit search_catalog_path q: 'william root', search_field: 'name'
    click_link 'Compact'
    within '.document-position-1' do
      within '.al-document-highlight' do
        expect(page).to have_css 'em', text: 'William'
        expect(page).to have_css 'em', text: 'Root'
      end
    end
  end
end
