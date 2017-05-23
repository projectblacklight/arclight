# frozen_string_literal: true

require 'spec_helper'

describe 'Google Form Request', type: :feature, js: true do
  context 'when container is present' do
    context 'repository is requestable' do
      it 'form is present with filled out values' do
        visit solr_document_path 'aoa271aspace_843e8f9f22bac69872d0802d6fffbb04'
        click_on 'In person'

        within '.al-sticky-sidebar form' do
          expect(page).to have_css(
            'input[name="entry.1980510262"][value$="catalog/aoa271aspace_843e8f9f22bac69872d0802d6fffbb04"]',
            visible: false
          )
          expect(page).to have_css('input[name="entry.619150170"][value="Alpha Omega Alpha Archives, 1894-1992"]',
                                   visible: false)
          expect(page).to have_css 'input[name="entry.14428541"][value="Alpha Omega Alpha"]', visible: false
          expect(page).to have_css 'input[name="entry.996397105"][value="aoa271"]', visible: false
          expect(page).to have_css 'input[name="entry.1125277048"][value="Box 1 Folder 1"]', visible: false
          expect(page).to have_css 'input[name="entry.862815208"][value$="William W. Root, n.d."]', visible: false
          expect(page).to have_css 'button[type="submit"]', text: 'Request container(s)'
        end
      end
      context 'repository is not requestable' do
        it 'form is absent' do
          visit solr_document_path 'm0198-xmlaspace_ref14_di4'
          expect(page).not_to have_css '.al-sticky-sidebar form'
        end
      end
    end
  end
  context 'when container is absent' do
    it 'form is absent' do
      visit solr_document_path 'aoa271aspace_238a0567431f36f49acea49ef576d408'
      expect(page).not_to have_css '.al-sticky-sidebar form'
    end
  end
  context 'in search results' do
    it 'shows up when item is requestable' do
      visit search_catalog_path q: '', search_field: 'all_fields'
      expect(page).to have_css 'form[action*="https://docs.google.com"]', count: 7
    end
  end
end
