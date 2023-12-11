# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Search queries' do
  describe 'multi-term queries' do
    context 'when a query has 4 terms, all present in a component' do
      xit 'returns the component' do
        visit search_catalog_path q: 'articles incorporation revised constitution', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Amendments to articles of incorporation and revised constitution/
      end
    end

    context 'when a query has 4 terms, 1 is nonsense' do
      xit 'requires all terms to match; no results' do
        visit search_catalog_path q: 'articles incorporation revised zzznonsensezzz', search_field: 'all_fields'
        expect(page).to have_css 'h2', text: /No results found/
      end
    end

    context 'when a query has 5 terms, 1 is nonsense' do
      xit 'can match on all but one; returns the component' do
        visit search_catalog_path q: 'articles incorporation revised constitution zzznonsensezzz', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Amendments to articles of incorporation and revised constitution/
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
        visit search_catalog_path q: 'aoa271aspace_2d7e583e94eb2b46d5dd1a0ec4cdca1f', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Dr. Root and L. Raymond Higgins/
      end
    end

    context 'container' do
      it 'returns a component with a matching container' do
        visit search_catalog_path q: '"box 92"', search_field: 'all_fields'
        expect(page).to have_css '.index_title', text: /Card index/
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
