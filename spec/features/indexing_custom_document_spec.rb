# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Indexing Custom Document', type: :feature do
  subject do
    Arclight::CustomDocument.from_xml(file)
  end

  let(:file) { File.read('spec/fixtures/ead/nlm/alphaomegaalpha.xml') }

  context 'solrizer' do
    let(:doc) { subject.to_solr }

    describe '#id' do
      context 'with periods' do
        let(:file) { File.read('spec/fixtures/ead/sul-spec/m0198_from_ASpace.xml') }

        it 'are replaced with hyphens in the identifier' do
          expect(doc['id']).to eq 'm0198-xml'
        end
      end

      context 'without periods' do
        it 'returns the plain identifier' do
          expect(doc['id']).to eq 'aoa271'
        end
      end
    end

    it '#bioghist' do
      expect(doc['bioghist_ssm'].first).to match(/^Alpha Omega Alpha Honor Medical Society was founded/)
    end

    it '#relatedmaterial' do
      expect(doc['relatedmaterial_ssm'].first).to match(/^An unprocessed collection includes/)
    end

    it '#separatedmaterial' do
      expect(doc['separatedmaterial_ssm'].first).to match(/^Birth, Apollonius of Perga brain/)
    end

    it '#otherfindaid' do
      expect(doc['otherfindaid_ssm'].first).to match(/^Li Europan lingues es membres del/)
    end

    it '#altformavail' do
      expect(doc['altformavail_ssm'].first).to match(/^Rig Veda a mote of dust suspended/)
    end

    it '#originalsloc' do
      expect(doc['originalsloc_ssm'].first).to match(/^Something incredible is waiting/)
    end

    it '#arrangement' do
      expect(doc['arrangement_ssm'].first).to eq 'Arranged into seven series.'
    end

    it '#acqinfo' do
      expect(doc['acqinfo_ssm'].first).to eq 'Donated by Alpha Omega Alpha.'
    end

    it '#appraisal' do
      expect(doc['appraisal_ssm'].first).to match(/^Corpus callosum something incredible/)
    end

    it '#custodhist' do
      expect(doc['custodhist_ssm'].first).to eq 'Maintained by Alpha Omega Alpha and the family of William Root.'
    end

    it '#processinfo' do
      expect(doc['processinfo_ssm'].first).to match(/^Processed in 2001\. Descended from astronomers\./)
    end

    it '#level' do
      expect(doc['level_ssm'].first).to eq 'collection'
      expect(doc['level_sim'].first).to eq 'Collection'
    end

    it '#unitid' do
      expect(doc['unitid_ssm'].first).to eq 'MS C 271'
    end

    context '#repository' do
      before do
        ENV['REPOSITORY_ID'] = nil
      end

      after do # ensure we reset these otherwise other tests will fail
        ENV['REPOSITORY_ID'] = nil
      end

      it 'matches EAD data' do
        expect(doc['repository_ssm'].first).to eq '1118 Badger Vine Special Collections'
        expect(doc['repository_sim'].first).to eq '1118 Badger Vine Special Collections'
      end

      context 'with REPOSITORY_ID' do
        it 'matches Repository configuration' do
          ENV['REPOSITORY_ID'] = 'nlm'
          expect(doc['repository_ssm'].first).to eq 'National Library of Medicine. History of Medicine Division'
          expect(doc['repository_sim'].first).to eq 'National Library of Medicine. History of Medicine Division'
        end
      end
    end

    it '#creator' do
      expect(doc['creators_ssim'].first).to eq 'Alpha Omega Alpha'
    end

    it '#extent' do
      expect(doc['extent_ssm'].first).to match(/^15\.0 linear feet/)
    end

    it '#accessrestrict' do
      expect(doc['accessrestrict_ssm'].first).to eq 'No restrictions on access.'
    end

    it '#scopecontent' do
      expect(doc['scopecontent_ssm'].first).to match(/^Correspondence, documents/)
    end

    it '#indexed-terms' do
      expect(doc['access_subjects_ssim']).to include 'Fraternizing'
      expect(doc['names_ssim']).to include 'Root, William Webster, 1867-1932'
      expect(doc['places_ssim']).to include 'Mindanao Island (Philippines)'
    end

    it '#normalized_title' do
      expect(doc['normalized_title_ssm'].first).to eq 'Alpha Omega Alpha Archives, 1894-1992'
    end

    it '#normalized_date' do
      expect(doc['normalized_date_ssm'].first).to eq '1894-1992'
    end

    it '#names_coll' do
      expect(doc['names_coll_ssim']).to include 'Bierring, Walter L. (Walter Lawrence), 1868-1961'
    end

    describe '#has_online_content' do
      context 'when a document has online content' do
        it 'is true' do
          expect(doc['has_online_content_ssim']).to eq [true]
        end
      end

      context 'when a document does not have online content' do
        let(:file) { File.read('spec/fixtures/ead/sul-spec/m0198_from_ASpace.xml') }

        it 'is false' do
          expect(doc['has_online_content_ssim']).to eq [false]
        end
      end
    end

    describe '#date_range' do
      it 'includes an array of all the years in a particular unit-date range described in YYYY/YYYY format' do
        date_range_field = doc['date_range_sim']
        expect(date_range_field).to be_an Array
        expect(date_range_field.length).to eq 99
        expect(date_range_field.first).to eq '1894'
        expect(date_range_field.last).to eq '1992'
      end
    end

    describe 'digital content' do
      context 'for a collection with a digital object' do
        it 'indexes the dao for the collection document' do
          objects = doc['digital_objects_ssm']
          expect(objects.length).to eq 1
          json = JSON.parse(objects.first)
          expect(json).to have_key 'label'
          expect(json).to have_key 'href'
        end
      end

      context 'for a collection without a digital object' do
        let(:file) { File.read('spec/fixtures/ead/sul-spec/m0198_from_ASpace.xml') }

        it 'does not include a digital objects field' do
          expect(doc['digital_objects_ssm']).to be_nil
        end
      end
    end
  end
end
