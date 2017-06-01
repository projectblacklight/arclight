# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Many component EAD', type: :feature do
  describe 'hierarchy', js: true do
    before { visit solr_document_path 'lc0100' }
    it 'includes all components' do
      click_link 'Contents'
      within '#contents' do
        expect(page).to have_css '.blacklight-file', count: 202
      end
    end
    it 'includes all children' do
      click_link 'Contents'
      within '#contents' do
        click_link 'View'
        within '#aspace_327a75c226d44aa1a769edb4d2f13c6e-collapsible-hierarchy' do
          expect(page).to have_css '.blacklight-item', count: 202
        end
      end
    end
  end
end
