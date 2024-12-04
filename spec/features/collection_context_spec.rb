# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Collection context', :js do
  let(:doc_id) { 'aoa271_aspace_6ea193f778e553ca9ea0d00a3e5a1891' }

  before do
    visit solr_document_path(id: doc_id)
  end

  describe 'highly nested item' do
    it 'highlights the correct context item' do
      expect(page).to have_css '.al-hierarchy-highlight', text: 'Initial Phase'
    end

    it 'siblings are not expanded' do
      expect(page).to have_css '.al-toggle-view-children.collapsed[href="#collapsible-hierarchy-aoa271_aspace_b70574c7229e6f237f780579cc04595d"]'
    end

    it 'direct ancestors are expanded' do
      expect(page).to have_css '#collapsible-hierarchy-aoa271_aspace_f934f1add34289f28bd0feb478e68275.show', visible: :visible
      expect(page).to have_css '#collapsible-hierarchy-aoa271_aspace_238a0567431f36f49acea49ef576d408.show', visible: :visible
      expect(page).to have_css '#collapsible-hierarchy-aoa271_aspace_563a320bb37d24a9e1e6f7bf95b52671.show', visible: :visible
    end

    it 'siblings above are hidden' do
      expect(page).to have_no_css '#aoa271_aspace_843e8f9f22bac69872d0802d6fffbb04'
    end
  end
end
