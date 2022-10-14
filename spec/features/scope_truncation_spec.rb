# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Scope truncation', type: :feature, js: true do
  # rubocop:disable RSpec/NoExpectationExample
  context 'in search results' do
    it 'is truncated' do
      visit search_catalog_path q: 'series iii', search_field: 'all_fields'
      truncation_works 'be a nyan cat'
    end
  end

  context 'respository path' do
    it 'is truncated' do
      visit arclight_engine.repository_path 'sul-spec'
      truncation_works 'include Yosemite'
    end
  end
  # rubocop:enable RSpec/NoExpectationExample
end

def truncation_works(text)
  expect(page).to have_link 'view more ▶'
  expect(page).to have_css '.al-document-abstract-or-scope', text: /#{text}/, visible: :all
  first(:link, 'view more ▶').click
  expect(page).to have_link 'view less ▼'
  expect(page).to have_css '.al-document-abstract-or-scope', text: /#{text}/, visible: :visible
end
