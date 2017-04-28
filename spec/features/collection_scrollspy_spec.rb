# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Collection Scrollspy', type: :feature do
  before do
    visit solr_document_path(id: 'aoa271')
  end
  it 'as a user scrolls, active class is added', js: true do
    expect(page).to have_css '.al-sticky-sidebar'
    expect(page).not_to have_css '.nav-link.active', text: 'Indexed Terms'
    page.driver.scroll_to(0, 10_000)
    expect(page).to have_css '.nav-link.active', text: 'Indexed Terms'
  end
end
