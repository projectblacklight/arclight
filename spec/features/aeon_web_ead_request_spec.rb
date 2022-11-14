# frozen_string_literal: true

require 'spec_helper'

describe 'Aeon Web EAD Request', js: true do
  context 'when EAD URL template is provided' do
    it 'creates a request link' do
      visit solr_document_path 'm0198-xml'

      within '#m0198-xmlaspace_ref11_d0s' do
        click_link 'Pages 1-78'
      end
      expect(page).to have_css(
        'a[href*="https://sample.request.com?Action=10&Form=31&Value=http%3A%2F%2Fexample.com%2FM0198.xml',
        text: 'Request'
      )
    end
  end
end
