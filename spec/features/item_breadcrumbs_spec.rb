# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Item breadcrumb', type: :feature do
  it 'results page shows navigable breadcrumbs' do
    visit search_catalog_path q: '', search_field: 'all_fields', per_page: 40
    document = page.all('article').find do |doc|
      doc.all('h3 a', text: 'Phase II: Expansion').present?
    end

    within document do
      expect(page).to have_css 'a', text: 'Series I: Administrative Records'
      expect(page).to have_css 'a', text: 'Reports'
      expect(page).to have_css 'a', text: 'Expansion Plan'
      click_link 'Expansion Plan'
    end
    expect(page).to have_css 'h1', text: 'Expansion Plan'
  end
end
