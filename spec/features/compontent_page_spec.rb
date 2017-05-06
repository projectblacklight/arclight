# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Collection Page', type: :feature do
  let(:doc_id) { 'aoa271aspace_843e8f9f22bac872d0802d6fffbb04' }

  before { visit solr_document_path(id: doc_id) }

  describe 'label/title' do
    it 'does not double escape entities in the heading' do
      expect(page).to have_css('h1', text: /^"A brief account of the origin of/)
      expect(page).not_to have_css('h1', text: /^&quot;A brief account of the origin of/)
    end
  end
end
