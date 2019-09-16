# frozen_string_literal: true

require 'spec_helper'

describe 'Aeon Web EAD Request', type: :feature, js: true do
  context 'when EAD URL template is provided' do
    it 'creates a request link' do
      visit solr_document_path 'umich-bhl-2016071'
      click_link 'Contents'
      within '.al-hierarchy-side-content' do
        expect(page).to have_css(
          'a[href*="https://sample.request.com?Action=10&Form=31&Value=http%3A%2F%2Fexample.com%2F2016071%2BAa%2B1.xml',
          text: 'Request'
        )
      end
    end
  end
end
