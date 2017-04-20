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

    it 'scope and arrangement has configured metadata' do
      within '#scope-and-arrangement' do
        expect(page).to have_css('dt', text: 'Scope and Content')
        expect(page).to have_css('dd', text: /^Correspondence, documents, records, photos/)

        expect(page).to have_css('dt', text: 'Arrangement')
        expect(page).to have_css('dd', text: /^Arranged into seven series\./)
      end
    end

    it 'related has configured metadata' do
      within '#related' do
        expect(page).to have_css('dt', text: 'Related material')
        expect(page).to have_css('dd', text: /^An unprocessed collection includes/)

        expect(page).to have_css('dt', text: 'Separated material')
        expect(page).to have_css('dd', text: /^Birth, Apollonius of Perga brain/)

        expect(page).to have_css('dt', text: 'Other finding aids')
        expect(page).to have_css('dd', text: /^Li Europan lingues es membres del/)

        expect(page).to have_css('dt', text: 'Alternative form available')
        expect(page).to have_css('dd', text: /^Rig Veda a mote of dust suspended/)

        expect(page).to have_css('dt', text: 'Location of originals')
        expect(page).to have_css('dd', text: /^Something incredible is waiting/)
      end
    end
  end
  describe 'navigation bar' do
    it 'has configured links' do
      within '.al-sidebar-navigation-overview' do
        expect(page).to have_css 'a[href="#summary"]', text: 'Summary'
        expect(page).to have_css 'a[href="#access-and-use"]', text: 'Access and Use'
        expect(page).to have_css 'a[href="#background"]', text: 'Background'
        expect(page).to have_css 'a[href="#related"]', text: 'Related'
      end
    end
  end
end
