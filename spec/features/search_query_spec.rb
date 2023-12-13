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
  end
end
