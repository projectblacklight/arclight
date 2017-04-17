# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Indexing Custom Document', type: :feature do
  subject do
    Arclight::CustomDocument.from_xml(File.read('spec/fixtures/ead/alphaomegaalpha.xml'))
  end

  context 'solrizer' do
    let(:doc) { subject.to_solr }

    it '#level' do
      expect(doc['level_ssm'].first).to eq 'collection'
      expect(doc['level_sim'].first).to eq 'Collection'
    end

    it '#unitid' do
      expect(doc['unitid_ssm'].first).to eq 'MS C 271'
    end

    it '#repository' do
      expect(doc['repository_ssm'].first).to eq '1118 Badger Vine Special Collections'
      expect(doc['repository_sim'].first).to eq '1118 Badger Vine Special Collections'
    end

    it '#creator' do
      expect(doc['creator_ssm'].first).to eq 'Alpha Omega Alpha'
      expect(doc['creator_sim'].first).to eq 'Alpha Omega Alpha'
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

    it '#names' do
      expect(doc['names_sim']).to include 'Root, William Webster, 1867-1932'
    end
  end
end
