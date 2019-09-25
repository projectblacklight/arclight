# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Component Page', type: :feature do
  let(:doc_id) { 'aoa271aspace_843e8f9f22bac69872d0802d6fffbb04' }

  before { visit solr_document_path(id: doc_id) }

  describe 'tabbed display' do
    it 'clicking contents toggles visibility', js: true do
      expect(page).to have_css '#context', visible: true
      expect(page).to have_css '#online-content', visible: false
      expect(page).to have_css '#access', visible: false
      click_link 'Online content'
      expect(page).to have_css '#context', visible: false
      expect(page).to have_css '#online-content', visible: true
      expect(page).to have_css '#access', visible: false
      click_link 'Access'
      expect(page).to have_css '#context', visible: false
      expect(page).to have_css '#contents', visible: false
      expect(page).to have_css '#access', visible: true
    end

    describe 'contents tab', js: true do
      let(:doc_id) { 'aoa271aspace_563a320bb37d24a9e1e6f7bf95b52671' }

      it 'is present and accessible' do
        expect(page).to have_css('li.nav-item a', text: 'Contents', visible: true)
        click_link 'Contents'
        expect(page).to have_css '#context', visible: false
        expect(page).to have_css '#contents', visible: true
        expect(page).to have_css '#online-content', visible: false
      end
    end
  end

  describe 'label/title' do
    it 'does not double escape entities in the heading' do
      expect(page).to have_css('h1', text: /^"A brief account of the origin of/)
      expect(page).not_to have_css('h1', text: /^&quot;A brief account of the origin of/)
    end
  end

  describe 'Indexed Terms names section' do
    it 'includes names dt subheading text' do
      expect(page).to have_css('dt.blacklight-names_ssim', text: 'Names:')
    end
    it 'includes names dd link text' do
      expect(page).to have_css('dd a', text: "Robertson's Crab House")
    end
  end

  describe 'Indexed Terms places section' do
    it 'includes places dt subheading text' do
      expect(page).to have_css('dt.blacklight-places_ssim', text: 'Places:')
    end
    it 'includes places dd link text' do
      expect(page).to have_css('dd a', text: 'Popes Creek (Md.)')
    end
  end

  describe 'Indexed Terms subjects section' do
    let(:doc_id) { 'aoa271aspace_01daa89087641f7fc9dbd7a10d3f2da9' }

    it 'includes subjects dt subheading text' do
      expect(page).to have_css('dt.blacklight-access_subjects_ssim', text: 'Subjects:')
    end
    it 'includes subjects dd link text' do
      expect(page).to have_css('dd.blacklight-access_subjects_ssim a', text: 'Records')
    end
  end

  describe 'metadata' do
    let(:doc_id) { 'aoa271aspace_dc2aaf83625280ae2e193beb3f4aea78' }

    it 'uses our rules for displaying containers' do
      expect(page).to have_css('dd', text: 'Box 1, Folder 4-5')
    end
    it 'shows misc notes' do
      expect(page).to have_css('dt', text: 'Appraisal information')
      expect(page).to have_css('dd', text: /^Materials for this group were selected/)
      expect(page).to have_css('dt', text: 'Custodial history')
      expect(page).to have_css('dd', text: /^These papers were maintained by the staff/)
    end
    it 'multivalued notes are rendered as paragaphs' do
      within 'dd.blacklight-appraisal_ssm' do
        expect(page).to have_css('p', count: 2)
      end
    end
  end

  describe 'collection context', js: true do
    it 'has ancestor component with badge having children count' do
      within '#collection-context' do
        expect(page).to have_css(
          'li a',
          text: 'Series I: Administrative Records, 1902-1976'
        )
        expect(page).to have_css('.al-number-of-children-badge', text: '25')
        expect(page).not_to have_css 'form.bookmark-toggle' # no bookmarks
      end
    end
    context 'siblings and highlighted self' do
      it 'has all siblings' do
        within '#collection-context' do
          expect(page).to have_css(
            'li.al-hierarchy-highlight:nth-child(1)',
            text: /"A brief account of the origin/
          )
          expect(page).to have_css 'li:nth-child(2)', text: 'Statements of purpose, c.1902'
          expect(page).to have_css 'li:nth-child(3)',
                                   text: 'Constitution - notes on drafting of constitution, c.1902-1903'
          expect(page).to have_css 'li', count: 33
        end
      end
    end
    it 'supports clicks within collection context' do
      within '#collection-context' do
        click_link('Statements of purpose, c.1902')
      end
      expect(page).to have_css 'h1', text: 'Statements of purpose, c.1902'
      within '#collection-context' do
        expect(page).to have_css 'li.al-hierarchy-highlight', text: 'Statements of purpose, c.1902'
        expect(page).to have_css '.document-title-heading', text: /"A brief account of the origin/
        expect(page).to have_css(
          '.document-title-heading',
          text: 'Constitution - notes on drafting of constitution, c.1902-1903'
        )
        click_link 'Constitution - notes on drafting of constitution, c.1902-1903'
      end
      expect(page).to have_css 'h1', text: 'Constitution - notes on drafting of constitution, c.1902-1903'
      within '#collection-context' do
        expect(page).to have_css(
          'li.al-hierarchy-highlight',
          text: 'Constitution - notes on drafting of constitution, c.1902-1903'
        )
        expect(page).to have_css '.document-title-heading', text: 'Statements of purpose, c.1902'
        expect(page).to have_css '.document-title-heading', text: 'Constitution and by-laws - drafts, 1902-1904'
      end
    end
    context 'duplicate titles' do
      let(:doc_id) { 'lc0100aspace_c5ef89d4ae68bb77e7c641f3edb3f1c8' }

      it 'does not highlight duplicate titles' do
        within '#collection-context .al-hierarchy-highlight' do
          expect(page).to have_css '.document-title-heading', text: 'Item AA201', count: 1
        end
      end
    end
  end

  describe 'access tab', js: true do
    it 'has visitation notes' do
      click_link 'Access'
      expect(page).to have_css 'dt', text: 'LOCATION OF THIS COLLECTION:'
      expect(page).to have_css 'dd', text: 'Building 38, Room 1E-21'
    end
    it 'has a restrictions and access' do
      click_link 'Access'
      expect(page).to have_css 'dt', text: 'PARENT RESTRICTIONS:'
      expect(page).to have_css 'dd', text: /^RESTRICTED: Access to these folders requires prior written approval./
      expect(page).to have_css 'dt', text: 'TERMS OF ACCESS:'
      expect(page).to have_css 'dd', text: /^Copyright was transferred to the public domain./
    end
    it 'has a contact' do
      click_link 'Access'
      expect(page).to have_css 'dt', text: 'CONTACT:'
      expect(page).to have_css 'dd', text: 'hmdref@nlm.nih.gov'
    end
  end

  describe 'breadcrumb' do
    it 'links home, collection, and parents' do
      within '.al-show-breadcrumb' do
        expect(page).to have_css 'a', text: 'National Library of Medicine. History of Medicine Division'
        expect(page).to have_css 'a', text: 'Alpha Omega Alpha Archives, 1894-1992'
        expect(page).to have_css 'a', text: 'Series I: Administrative Records, 1902-1976, bulk 1975-1976'
        expect(page).to have_css 'a', count: 3
      end
    end
  end
end
