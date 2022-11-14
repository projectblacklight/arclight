# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Many component EAD' do
  describe 'hierarchy', js: true do
    before { visit solr_document_path 'lc0100' }

    it 'includes all components' do
      within '#collection-context' do
        expect(page).to have_css 'li.al-collection-context', count: 202
      end
    end

    it 'includes all children' do
      within '#collection-context' do
        click_link 'View'
        click_link 'Expand'
        within '#lc0100aspace_327a75c226d44aa1a769edb4d2f13c6e-collapsible-hierarchy' do
          expect(page).to have_css 'li.al-collection-context', count: 202
        end
      end
    end
  end
end
