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
  it 'a show view is present with an item' do
    visit solr_document_path(id: 'aoa271')
    expect(page).to have_css 'h1', text: 'aoa271'
  end
end
