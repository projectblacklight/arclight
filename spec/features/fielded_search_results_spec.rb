# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Field-based search results', type: :feature do
  describe 'searches by' do
    context '#all_fields' do
      context 'for collections, fielded content is searchable by' do
        it 'title' do
          visit search_catalog_path q: 'student life', search_field: 'all_fields', f: { level_sim: ['Collection'] }
          within('.document-position-0') do
            expect(page).to have_css '.index_title', text: /Stanford University student life photograph album/
          end
        end
        it 'biographical note' do
          visit search_catalog_path q: 'boorishness', search_field: 'all_fields'
          within('.document-position-0') do
            expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
          end
        end
        it 'bioghist note' do
          visit search_catalog_path q: 'Hippocratic oath', search_field: 'all_fields'
          within('.document-position-0') do
            expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
          end
        end
      end
      context 'for components, fielded content is searchable by' do
        it 'title' do
          visit search_catalog_path q: 'a brief account', search_field: 'all_fields', f: { level_sim: ['File'] }
          within('.document-position-0') do
            expect(page).to have_css '.index_title', text: /A brief account/
          end
        end
        it 'userestrict note' do
          visit search_catalog_path q: 'Original photographs must be handled using gloves', search_field: 'all_fields'
          within('.document-position-0') do
            expect(page).to have_css '.index_title', text: /Series VI: Photographs/
          end
        end
      end
    end

    it '#keyword' do
      visit search_catalog_path q: 'a brief account', search_field: 'keyword'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /A brief account/
      end
    end

    it '#name' do
      visit search_catalog_path q: 'root', search_field: 'name'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#place' do
      visit search_catalog_path q: 'island', search_field: 'place'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#subject' do
      visit search_catalog_path q: 'medicine', search_field: 'subject'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#title' do
      visit search_catalog_path q: 'motto', search_field: 'title'
      within('.document-position-0') do
        expect(page).to have_css '.index_title', text: /Plans for motto/
      end
      within('.document-position-1') do
        expect(page).to have_css '.index_title', text: /Dr. Root and L. Raymond Higgins/
      end
    end
  end
end
