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
  it 'has a title of Arclight' do
    expect(page.body).to include('<title>Arclight</title>')
  end
  context 'search dropdown' do
    it 'has all fields' do
      within('.search-field') do
        expect(page).to have_css 'option', text: 'All Fields'
      end
    end
    it 'has several fielded' do
      within('.search-field') do
        expect(page).to have_css 'option', text: 'Keyword'
        expect(page).to have_css 'option', text: 'Name'
        expect(page).to have_css 'option', text: 'Place'
        expect(page).to have_css 'option', text: 'Subject'
        expect(page).to have_css 'option', text: 'Title'
      end
    end
  end
end
