# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Collection Page', type: :feature do
  before do
    visit solr_document_path(id: 'aoa271')
  end
  describe 'custom metadata sections' do
    it 'summary has configured metadata' do
      within '#summary' do
        expect(page).to have_css('dt', text: 'Creator')
        expect(page).to have_css('dd', text: 'Alpha Omega Alpha')
        expect(page).to have_css('dt', text: 'Abstract')
        expect(page).to have_css('dd', text: /was founded in 1902/)
        expect(page).to have_css('dt', text: 'Extent')
        expect(page).to have_css('dd', text: /15.0 linear feet/)
        expect(page).to have_css('dt', text: 'Preferred citation')
        expect(page).to have_css('dd', text: /Medicine, Bethesda, MD/)
      end
    end
    it 'access and use has configured metadata' do
      within '#access-and-use' do
        expect(page).to have_css('dt', text: 'Conditions Governing Access')
        expect(page).to have_css('dd', text: 'No restrictions on access.')
        expect(page).to have_css('dt', text: 'Terms Of Use')
        expect(page).to have_css('dd', text: /Copyright was transferred/)
      end
    end

    it 'background has configured metadata' do
      within '#background' do
        expect(page).to have_css('dt', text: 'Biographical / Historical')
        expect(page).to have_css('dd', text: /^Alpha Omega Alpha Honor Medical Society was founded/)
      end
    end
  end
  describe 'navigation bar' do
    it 'has configured links' do
      within '.al-sidebar-navigation-overview' do
        expect(page).to have_css 'a[href="#summary"]', text: 'Summary'
        expect(page).to have_css 'a[href="#access-and-use"]', text: 'Access and Use'
        expect(page).to have_css 'a[href="#background"]', text: 'Background'
      end
    end
  end
end
