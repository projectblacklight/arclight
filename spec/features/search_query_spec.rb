# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Search queries' do
  describe 'multi-term queries' do
    context 'when a query has 4 terms, all present in a component' do
      it 'returns the component' do
        visit search_catalog_path q: 'articles incorporation revised constitution', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Amendments to articles of incorporation and revised constitution/
      end
    end

    context 'when a query has 4 terms, 1 is nonsense' do
      it 'requires all terms to match; no results' do
        visit search_catalog_path q: 'articles incorporation revised zzznonsensezzz', search_field: 'all_fields'
        expect(page).to have_css 'h2', text: /No results found/
      end
    end

    context 'when a query has 5 terms, 1 is nonsense' do
      it 'can match on all but one; returns the component' do
        visit search_catalog_path q: 'articles incorporation revised constitution zzznonsensezzz', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Amendments to articles of incorporation and revised constitution/
      end
    end

    context 'when two terms match two docs but proximity differs (pf test)' do
      it 'counts the doc where the terms are in close proximity as more relevant' do
        visit search_catalog_path q: 'splendiferous escapades', search_field: 'all_fields'
        within('.document-position-1') do
          expect(page).to have_css '.al-document-abstract-or-scope',
                                   text: /This will test the splendiferous escapades phrase/
        end
      end

      it 'counts the doc where the terms are are far apart as less relevant' do
        visit search_catalog_path q: 'splendiferous escapades', search_field: 'all_fields'
        within('.document-position-2') do
          expect(page).to have_css '.al-document-abstract-or-scope',
                                   text: /This splendiferous test will help/
        end
      end
    end
  end

  describe 'default all fields search for' do
    context 'EAD ID' do
      it 'returns a collection with a matching EAD ID' do
        visit search_catalog_path q: 'umich-bhl-851981', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Interlochen Center for The Arts records/
      end
    end

    context 'component ref ID' do
      it 'returns a component with a matching ref' do
        visit search_catalog_path q: 'aspace_563a320bb37d24a9e1e6f7bf95b52671', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Series I: Administrative Records/
      end
    end

    context 'component full ID (with eadid & ref)' do
      it 'returns a component with a matching full ID' do
        visit search_catalog_path q: 'aoa271_aspace_2d7e583e94eb2b46d5dd1a0ec4cdca1f', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Dr. Root and L. Raymond Higgins/
      end
    end

    context 'container' do
      it 'returns a component with a matching container' do
        visit search_catalog_path q: '"box 92"', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Card index/
      end
    end

    context 'language' do
      it 'returns a component with a matching language' do
        visit search_catalog_path q: 'english', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Stanford University student life photograph album/
      end
    end

    context 'terms appearing in different ancestor component titles' do
      it 'returns a component where one term hit is only in its parent title' do
        visit search_catalog_path q: 'administrative hippocrates', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /The constitution of the Alpha Omega/
      end
    end
  end
end
