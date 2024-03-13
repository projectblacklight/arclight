# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Grouped search results' do
  it 'displays collection group information' do
    visit search_catalog_path q: 'student life', group: 'true'
    within '.al-grouped-title-bar' do
      expect(page).to have_css 'h3 a', text: /photograph album/
      expect(page).to have_css '.al-document-abstract-or-scope', text: /track meets/
      expect(page).to have_css('.al-document-extent.badge', count: 3)
    end
    within '.grouped-documents' do
      expect(page).to have_css 'article', count: 2
    end
  end

  it 'displays breadcrumbs only for component parents' do
    visit search_catalog_path q: 'alpha omega', group: 'true'
    within first('.breadcrumb-links') do
      expect(page).to have_link 'National Library of Medicine. History of Medicine Division'
      expect(page).to have_link count: 1 # Only one link is in the .breadcrumb-links
    end
    expect(page).to have_css '.breadcrumb-links a', text: /Series/
  end

  it 'displays icons for results' do
    visit search_catalog_path q: 'alpha omega', group: 'true'
    within '.grouped-documents' do
      expect(page).to have_css '.document-type-icon', count: 3
    end
  end

  it 'has link to repository' do
    visit search_catalog_path q: 'alpha omega', group: 'true'
    expect(page).to have_css '.al-grouped-repository a', text: /National Library of Medicine/
  end

  it 'links to additional results in collection' do
    visit search_catalog_path q: 'alpha omega', group: 'true'
    expect(page).to have_css '.al-grouped-more', text: /Top 3 results/
    expect(page).to have_css(
      '.al-grouped-more a[href*="/catalog?f%5Bcollection%5D%5B%5D=Alpha+Omega+Alpha+Archives%2C+1894-1992"]',
      text: 'view all 39'
    )
  end

  it 'retains existing facet selections when viewing all in a collection' do
    visit search_catalog_path q: 'large sample', group: 'true', f: { level: ['File'] }
    expect(page).to have_css '.al-grouped-more', text: /Top 3 results/
    expect(page).to have_css(
      '.al-grouped-more a[href*="/catalog?f%5Bcollection%5D%5B%5D=Large+collection+sample%2C+1843-1872&f%5Blevel%5D%5B%5D=File&q=large+sample"]',
      text: 'view all 202'
    )
  end

  context 'when in compact view' do
    it 'does not render the collection abstract/scope' do
      visit search_catalog_path q: 'alpha omega', group: 'true', view: 'compact'

      within '.al-grouped-title-bar' do
        expect(page).to have_css 'h3 a', text: /Alpha/
        expect(page).to have_no_css '.al-document-abstract-or-scope', text: /founded in 1902/
        expect(page).to have_no_css('.badge')
      end
    end
  end
end
