# frozen_string_literal: true

require 'spec_helper'

describe 'Aeon Web EAD Request', type: :feature, js: true do
  context 'when EAD URL template is provided' do
    it 'creates a request link' do
      visit solr_document_path 'm0198-xml'
      click_link 'Contents'

      within '.document-position-0' do
        expect(page).to have_css(
          'a[href*="https://sample.request.com?Action=10&Form=31&Value=http%3A%2F%2Fexample.com%2FM0198.xml',
          text: 'Request'
        )
      end
    end
  end
end
