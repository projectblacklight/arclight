# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Indexing Custom Document', type: :feature do
  subject do
    Arclight::CustomDocument.from_xml(file)
  end

  let(:file) { File.read('spec/fixtures/ead/alphaomegaalpha.xml') }

  context 'solrizer' do
    let(:doc) { subject.to_solr }

    describe '#id' do
      context 'with periods' do
        let(:file) { File.read('spec/fixtures/ead/m0198_from_ASpace.xml') }

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
        ENV['REPOSITORY_FILE'] = 'spec/fixtures/config/repositories.yml'
      end

      after do # ensure we reset these otherwise other tests will fail
        ENV['REPOSITORY_ID'] = nil
        ENV['REPOSITORY_FILE'] = nil
      end

      it 'matches EAD data' do
        expect(doc['repository_ssm'].first).to eq '1118 Badger Vine Special Collections'
        expect(doc['repository_sim'].first).to eq '1118 Badger Vine Special Collections'
      end

      context 'with REPOSITORY_ID' do
        it 'matches Repository configuration' do
          ENV['REPOSITORY_ID'] = 'US-CaS-BVSC'
          expect(doc['repository_ssm'].first).to eq 'US CaS Badger Vine Special Collections'
          expect(doc['repository_sim'].first).to eq 'US CaS Badger Vine Special Collections'
        end
      end
    end

    it '#creator' do
      expect(doc['creators_ssim'].first).to eq 'Alpha Omega Alpha'
    end

    it '#extent' do
      expect(doc['extent_ssm'].first).to match(/^15\.0 linear feet/)
    end

    it '#unitdate' do
      expect(doc['unitdate_ssm'].first).to eq '1894-1992'
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

    describe '#has_online_content' do
      context 'when a document has online content' do
        it 'is true' do
          expect(doc['has_online_content_ssm']).to eq [true]
        end
      end

      context 'when a document does not have online content' do
        let(:file) { File.read('spec/fixtures/ead/m0198_from_ASpace.xml') }

        it 'is false' do
          expect(doc['has_online_content_ssm']).to eq [false]
        end
      end
    end

    describe '#date_range' do
      it 'includes an array of all the years in a particular unit-date range described in YYYY/YYYY format' do
        date_range_field = doc['date_range_sim']
        expect(doc['unitdate_ssm']).to eq ['1894-1992'] # the field the range is derived from
        expect(date_range_field).to be_an Array
        expect(date_range_field.length).to eq 99
        expect(date_range_field.first).to eq '1894'
        expect(date_range_field.last).to eq '1992'
      end

      # We don't have EADs in our fixtures that exhibit the following behaviors
      it 'is nil for non normal dates'
      it 'handles normal unitdates formatted as YYYY/YYYY when the years are the same'
      it 'handles normal unitdates formatted as YYYY'
    end
  end
end
