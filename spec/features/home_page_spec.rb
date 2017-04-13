# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Home Page', type: :feature do
  before { visit '/' }
  it 'has a custom heading' do
    expect(page).to have_css 'h1', text: 'Archival Collections at Institution'
  end
  it 'has a search with a jumbotron' do
    expect(page).to have_css '.jumbotron .search-query-form'
  end
  it 'does not have a sidebar' do
    expect(page).not_to have_css '#sidebar'
  end
  it 'does not have content' do
    expect(page).not_to have_css '#content'
  end
  it 'does not have a search-navbar' do
    expect(page).not_to have_css '#search-navbar'
  end
end
