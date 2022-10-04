# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Highlighted search results', type: :feature do
  describe 'when querying' do
    describe '#all_fields' do
      it 'highlights the snippets' do
        visit search_catalog_path q: 'student life', search_field: 'all_fields'
        within '.document-position-1' do
          within '.al-document-highlight' do
            expect(page).to have_css 'em', text: /^student$/, count: 2
            expect(page).to have_css 'em', text: 'students', count: 1
            expect(page).to have_css 'em', text: 'life', count: 1
          end
        end
      end

      it 'does not highlight the snippets on empty query' do
        visit search_catalog_path q: '', search_field: 'all_fields'
        within '.document-position-1' do
          expect(page).not_to have_css '.al-document-highlight'
        end
      end
    end

    describe '#name' do
      it 'highlights the snippets' do
        visit search_catalog_path q: 'william root', search_field: 'name'
        within '.document-position-1' do
          within '.al-document-highlight' do
            expect(page).to have_css 'em', text: 'William', count: 3
            expect(page).to have_css 'em', text: 'Root', count: 3
          end
        end
      end
    end
  end
end
