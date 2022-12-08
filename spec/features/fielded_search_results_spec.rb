# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Field-based search results' do
  describe 'searches by' do
    describe '#all_fields' do
      context 'for collections, fielded content is searchable by' do
        it 'title' do
          visit search_catalog_path q: 'student life', search_field: 'all_fields', f: { level: ['Collection'] }
          within('.document-position-1') do
            expect(page).to have_css '.index_title', text: /Stanford University student life photograph album/
          end
        end

        it 'biographical note' do
          visit search_catalog_path q: 'boorishness', search_field: 'all_fields'
          within('.document-position-1') do
            expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
          end
        end

        it 'bioghist note' do
          visit search_catalog_path q: 'Hippocratic oath', search_field: 'all_fields'
          within('.document-position-1') do
            expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
          end
        end

        it 'odd note without <p> tag' do
          visit search_catalog_path q: 'Jim Labosier', search_field: 'all_fields'
          within('.document-position-1') do
            expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
          end
        end

        it 'relatedmaterial note with nested structured tags within a <p> tag' do
          visit search_catalog_path q: 'HMD MS ACC 496', search_field: 'all_fields'
          within('.document-position-1') do
            expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
          end
        end
      end

      context 'for components, fielded content is searchable by' do
        it 'title' do
          visit search_catalog_path q: 'a brief account', search_field: 'all_fields', f: { level: ['File'] }
          within('.document-position-1') do
            expect(page).to have_css '.index_title', text: /A brief account/
          end
        end

        it 'userestrict note' do
          visit search_catalog_path q: 'Original photographs must be handled using gloves', search_field: 'all_fields'
          within('.document-position-1') do
            expect(page).to have_css '.index_title', text: /Series VI: Photographs/
          end
        end

        it 'unitid' do
          visit search_catalog_path q: 'MS C 271.VI', search_field: 'all_fields'
          within('.document-position-1') do
            expect(page).to have_css '.index_title', text: /Series VI: Photographs/
          end
        end
      end
    end

    describe '#keyword' do
      it 'does a narrow search that has 1 hit' do
        visit search_catalog_path q: '"a brief account"', search_field: 'keyword'
        expect(page).to have_css '.index_title', count: 1
        within('.document-position-1') do
          expect(page).to have_css '.index_title', text: /A brief account/
        end
      end

      it 'matches titles with a boost for multiple hits' do
        visit search_catalog_path q: 'alpha omega alpha archives', search_field: 'keyword'
        expect(page).to have_css '.index_title', count: 6
        within('.document-position-1') do
          expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives, 1894-1992/
        end
      end
    end

    it '#name' do
      visit search_catalog_path q: 'root', search_field: 'name'
      within('.document-position-1') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#place' do
      visit search_catalog_path q: 'island', search_field: 'place'
      within('.document-position-1') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#subject' do
      visit search_catalog_path q: 'medicine', search_field: 'subject'
      within('.document-position-1') do
        expect(page).to have_css '.index_title', text: /Alpha Omega Alpha Archives/
      end
    end

    it '#title' do
      visit search_catalog_path q: 'motto', search_field: 'title'
      within('.document-position-1') do
        expect(page).to have_css '.index_title', text: /Plans for motto/
      end
      within('.document-position-2') do
        expect(page).to have_css '.index_title', text: /Dr. Root and L. Raymond Higgins/
      end
    end
  end
end
