# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Collection Page' do
  let(:doc_id) { 'aoa271' }
  let(:download_config) do
    ActiveSupport::HashWithIndifferentAccess.new(
      default: {
        pdf: {
          href: 'http://example.com/sample.pdf',
          size: '1.23MB'
        },
        ead: {
          href: 'http://example.com/sample.xml',
          size: 123_456
        }
      }
    )
  end

  before do
    allow(Arclight::DocumentDownloads).to receive(:config).and_return(download_config)
    visit solr_document_path(id: doc_id)
  end

  describe 'arclight document header' do
    it 'includes a div with the repository and collection ID' do
      within('.al-show-breadcrumb') do
        expect(page).to have_content 'National Library of Medicine. History of Medicine Division'
      end
    end
  end

  describe 'online content indicator' do
    context 'when there is online content available' do
      it 'is rendered' do
        expect(page).to have_css('.card', text: 'Online content')
      end
    end

    context 'when there is no online content available' do
      let(:doc_id) { 'm0198-xml' }

      it 'is not rendered' do
        expect(page).not_to have_css('.card', text: 'Online content')
      end
    end
  end

  describe 'custom metadata sections' do
    it 'summary has configured metadata' do
      within '#summary' do
        expect(page).to have_css('dt', text: 'Creator')
        expect(page).to have_css('dd', text: 'Alpha Omega Alpha')
        expect(page).to have_css('dt', text: 'Abstract')
        expect(page).to have_css('dd', text: /was founded in 1902/)
        expect(page).to have_css('dt', text: 'Extent')
        expect(page).to have_css('dd', text: /15.0 linear feet/)
        expect(page).to have_css('dt', text: 'Preferred citation')
        expect(page).to have_css('dd', text: /Medicine, Bethesda, MD/)
      end
    end

    it 'html-formatted notes render with paragraphs intact' do
      within 'dd.blacklight-bioghist' do
        expect(page).to have_css('p', count: 4)
        expect(page).to have_css('p', text: /^Alpha Omega Alpha Honor Medical Society was founded/)
        expect(page).to have_css('p', text: /^Root and his fellow medical students/)
      end
      within 'dd.blacklight-abstract' do
        expect(page).to have_css('p', count: 2)
      end
    end

    it 'background has configured metadata' do
      within '#background' do
        expect(page).to have_css('dt', text: 'Scope and content')
        expect(page).to have_css('dd', text: /^Correspondence, documents, records, photos/)

        expect(page).to have_css('dt', text: 'Biographical / historical')
        expect(page).to have_css('dd', text: /^Alpha Omega Alpha Honor Medical Society was founded/)

        expect(page).to have_css('dt', text: 'Acquisition information')
        expect(page).to have_css('dd', text: 'Donated by Alpha Omega Alpha.')

        expect(page).to have_css('dt', text: 'Appraisal information')
        expect(page).to have_css('dd', text: /^Corpus callosum something incredible/)

        expect(page).to have_css('dt', text: 'Custodial history')
        expect(page).to have_css('dd', text: 'Maintained by Alpha Omega Alpha and the family of William Root.')

        expect(page).to have_css('dt', text: 'Processing information')
        expect(page).to have_css('dd', text: /^Processed in 2001\. Descended from astronomers\./)

        expect(page).to have_css('dt', text: 'Accruals')
        expect(page).to have_css('dd', text: /^No further materials are expected/)

        expect(page).to have_css('dt', text: 'Arrangement')
        expect(page).to have_css('dd', text: /^Arranged into seven series\./)

        expect(page).to have_css('dt', text: 'Rules or conventions')
        expect(page).to have_css('dd', text: /^Finding aid prepared using Rules for Archival Description/)
      end
    end

    it 'related has configured metadata' do
      within '#related' do
        expect(page).to have_css('dt', text: 'Related material')
        expect(page).to have_css('dd', text: /^An unprocessed collection includes/)

        expect(page).to have_css('dt', text: 'Separated material')
        expect(page).to have_css('dd', text: /^Birth, Apollonius of Perga brain/)

        expect(page).to have_css('dt', text: 'Other finding aids')
        expect(page).to have_css('dd', text: /^Li Europan lingues es membres del/)

        expect(page).to have_css('dt', text: 'Alternative form available')
        expect(page).to have_css('dd', text: /^Rig Veda a mote of dust suspended/)

        expect(page).to have_css('dt', text: 'Location of originals')
        expect(page).to have_css('dd', text: /^Something incredible is waiting/)
      end
    end

    it 'indexed terms has configured metadata' do
      within '#indexed-terms' do
        expect(page).to have_css('dt', text: 'Subjects')
        expect(page).to have_css('dt', text: 'Names')
        expect(page).to have_css('dt', text: 'Places')
        expect(page).to have_css('dd', text: 'Societies')
        expect(page).to have_css('dd', text: 'Photographs')
        expect(page).to have_css('dd', text: 'Medicine')
        expect(page).to have_css('dd', text: 'Alpha Omega Alpha')
        expect(page).to have_css('dd', text: 'Root, William Webster, 1867-1932')
        expect(page).to have_css('dd', text: 'Bierring, Walter L. (Walter Lawrence), 1868-1961')
        expect(page).to have_css('dd', text: 'Mindanao Island (Philippines)')
        expect(page).not_to have_css('dd', text: 'Higgins, L. Raymond')
      end
    end

    it 'indexed name terms link to the appropriate name facet' do
      name = 'Root, William Webster, 1867-1932'
      within '#indexed-terms' do
        click_link name
      end

      within '.blacklight-names.facet-limit-active' do
        expect(page).to have_css('.facet-label .selected', text: name)
      end
    end

    context 'sections that do not have metadata' do
      let(:doc_id) { 'm0198-xml' }

      it 'are not displayed' do
        expect(page).not_to have_css('.al-show-sub-heading', text: 'Related')
      end
    end
  end

  describe 'navigation bar' do
    it 'has configured links' do
      within '.al-sidebar-navigation-context' do
        expect(page).to have_link 'Summary', href: /#summary/
        expect(page).to have_link 'Background', href: /#background/
        expect(page).to have_link 'Related', href: /#related/
        expect(page).to have_link 'Indexed terms', href: /#indexed-terms/
      end
    end

    context 'for sections that do not have metadata' do
      let(:doc_id) { 'm0198-xml' }

      it 'does not include links to those sections' do
        within '.al-sidebar-navigation-context' do
          expect(page).not_to have_link 'Related'
        end
      end
    end
  end

  describe 'context and contents' do
    describe 'interactions', js: true do
      it 'contents contain linked level 1 components' do
        within '#collection-context' do
          click_link 'Series I: Administrative Records, 1902-1976'
        end
        expect(page).to have_css '.show-document', text: /Series I: Administrative Records/
      end

      it 'sub components are viewable and expandable' do
        within '#collection-context' do
          within '#aoa271aspace_563a320bb37d24a9e1e6f7bf95b52671' do
            click_link 'View'
            within '#aoa271aspace_dc2aaf83625280ae2e193beb3f4aea78.al-collection-context' do
              expect(page).to have_link 'Constitution and by-laws'
            end
            click_link 'Expand'
            expect(page).to have_link 'Reports'
            el = find_by_id('aoa271aspace_238a0567431f36f49acea49ef576d408')
            evaluate_script "window.scrollTo(0,#{el.rect.y - 100})"
            sleep 1
            within '#aoa271aspace_238a0567431f36f49acea49ef576d408' do
              click_link 'View'
              expect(page).to have_link 'Expansion Plan'
              within '#aoa271aspace_f934f1add34289f28bd0feb478e68275' do
                click_link 'View'
                expect(page).to have_link 'Initial Phase'
                expect(page).to have_link 'Phase II: Expansion'
              end
            end
          end
        end
      end

      it 'includes the number of direct children of the component' do
        within '#aoa271aspace_563a320bb37d24a9e1e6f7bf95b52671' do
          expect(page).to have_css(
            '.al-number-of-children-badge',
            text: /25/
          )
        end
      end

      it 'clicking contents does not change the session results view context' do
        visit search_catalog_path q: '', search_field: 'all_fields'

        expect(page).to have_css('#documents.documents-list')
        expect(page).not_to have_css('#documents.documents-hierarchy')
      end
    end
  end

  describe 'breadcrumb' do
    it 'links repository and shows collection header 1 text' do
      within '.al-show-breadcrumb' do
        expect(page).to have_link 'Home'
        expect(page).to have_link 'National Library of Medicine. History of Medicine Division'
        expect(page).to have_css 'span', text: 'Alpha Omega Alpha Archives, 1894-1992'
      end
    end
  end

  context 'content with file downloads', js: true do
    let(:doc_id) { 'a0011-xmlaspace_ref6_lx4' }

    it 'renders links to the files for download' do
      within '.al-show-actions-box-downloads-container' do
        click_button 'Download'
        expect(page).to have_link 'Finding aid'
        expect(page).to have_link 'EAD'
      end
    end
  end

  describe 'actions box' do
    before do
      visit solr_document_path(id: doc_id)
    end

    context 'with EAD documents which require Aeon requests' do
      let(:doc_id) { 'm0198-xmlaspace_ref11_d0s' }

      it 'renders links to the Aeon request form' do
        expect(page).to have_css '.al-request'
        expect(page).to have_css '.al-request a[href^="https://sample.request.com"]'
      end
    end
  end
end
