# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Autocomplete', type: :feature, js: true do
  context 'site-wide search form' do
    it 'is configured properly to allow non-prefix autocomplete' do
      visit '/catalog'
      find_by_id('q').send_keys 'by-laws'
      expect(page).to have_content 'amendments to articles'
      send_keys(:arrow_down)
      send_keys(:tab)
      expect(page).to have_field('search for', with: 'amendments to articles of incorporation and revised constitution and              by-laws, 1960')
    end
  end
end
