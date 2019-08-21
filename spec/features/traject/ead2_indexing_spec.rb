# frozen_string_literal: true

require 'spec_helper'
require 'byebug'

describe 'EAD 2 traject indexing', type: :feature do
  subject(:result) do
    indexer.map_record(record)
  end

  let(:record) do
    Traject::NokogiriReader.new(
      File.read(
        Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'sul-spec', 'a0011.xml')
      ).to_s,
      {}
    ).to_a.first
  end

  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Arclight::Engine.root.join('lib/arclight/traject/ead2_config.rb'))
    end
  end

  before do
    ENV['REPOSITORY_ID'] = nil
  end

  after do # ensure we reset these otherwise other tests will fail
    ENV['REPOSITORY_ID'] = nil
  end

  describe 'solr fields' do
    before do
      ENV['REPOSITORY_ID'] = 'sul-spec'
    end

    it 'id' do
      expect(result['id'].first).to eq 'a0011-xml'
      expect(result['ead_ssi'].first).to eq 'a0011-xml'
    end
    it 'title' do
      %w[title_ssm title_teim].each do |field|
        expect(result[field]).to include 'Stanford University student life photograph album'
      end
      expect(result['normalized_title_ssm']).to include 'Stanford University student life photograph album, circa 1900-1906'
    end
    it 'level' do
      expect(result['level_ssm']).to eq ['collection']
      expect(result['level_sim']).to eq ['Collection']
    end
    it 'dates' do
      expect(result['normalized_date_ssm']).to include 'circa 1900-1906'
      expect(result['unitdate_bulk_ssim']).to be_nil
      expect(result['unitdate_inclusive_ssim']).to include 'circa 1900-1906'
      expect(result['unitdate_other_ssim']).to be_nil
    end
    it 'repository' do
      %w[repository_sim repository_ssm].each do |field|
        expect(result[field]).to include 'Stanford University Libraries. Special Collections and University Archives'
      end
    end
    it 'unitid' do
      expect(result['unitid_ssm']).to eq ['A0011']
    end
    it 'creator' do
      %w[creator_ssm creator_ssim creator_corpname_ssm creator_corpname_ssim creators_ssim creator_sort].each do |field|
        expect(result[field]).to eq ['Stanford University']
      end
    end

    it 'places' do
      expect(result['places_ssim']).to eq ['Yosemite National Park (Calif.)']
    end

    describe 'components' do
      let(:first_component) { result['components'].first }

      it 'ref' do
        %w[ref_ssm ref_ssi].each do |field|
          expect(first_component[field]).to include 'aspace_ref6_lx4'
        end
      end
      it 'id' do
        expect(first_component).to include 'id' => ['a0011-xmlaspace_ref6_lx4']
      end
      it 'repository' do
        %w[repository_sim repository_ssm].each do |field|
          expect(first_component[field]).to include 'Stanford University Libraries. Special Collections and University Archives'
        end
      end
      it 'collection has normalized title' do
        %w[collection_sim collection_ssm].each do |field|
          expect(first_component[field]).to include 'Stanford University student life photograph album, circa 1900-1906'
        end
      end
      it 'creator' do
        %w[collection_creator_ssm].each do |field|
          expect(first_component[field]).to eq ['Stanford University']
        end
      end
    end
  end

  describe 'large component list' do
    let(:record) do
      Traject::NokogiriReader.new(
        File.read(
          Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'sample', 'large-components-list.xml')
        ).to_s,
        {}
      ).to_a.first
    end

    it 'selects the components' do
      expect(result['components'].length).to eq 404
    end

    context 'when nested component' do
      let(:nested_component) { result['components'].find { |c| c['id'] == ['lc0100aspace_32ad9025a3a286358baeae91b5d7696e'] } }

      it 'correctly determines component level' do
        expect(nested_component['component_level_isim']).to eq [2]
      end

      it 'parent' do
        expect(nested_component['parent_ssm']).to eq %w[lc0100 aspace_327a75c226d44aa1a769edb4d2f13c6e]
        expect(nested_component['parent_ssi']).to eq ['aspace_327a75c226d44aa1a769edb4d2f13c6e']
      end

      it 'parent_unittitles' do
        expect(nested_component['parent_unittitles_ssm']).to eq ['Large collection sample, 1843-1872', 'File 1']
      end
    end
  end

  describe 'alphaomegaalpha list' do
    let(:record) do
      Traject::NokogiriReader.new(
        File.read(
          Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
        ).to_s,
        {}
      ).to_a.first
    end

    it 'selects the components' do
      expect(result['components'].length).to eq 37
    end


    context 'when nested component' do
      let(:self_access_restrict_component) { result['components'].find { |c| c['ref_ssi'] == ['aspace_dba76dab6f750f31aa5fc73e5402e71d'] } }
      let(:parent_access_restrict_component) { result['components'].find { |c| c['ref_ssi']== ['aspace_72f14d6c32e142baa3eeafdb6e4d69be'] } }
      let(:access_terms_component) { result['components'].find { |c| c['ref_ssi'] == ['aspace_563a320bb37d24a9e1e6f7bf95b52671'] } }
      
      it 'has access restrict' do
        expect(self_access_restrict_component['parent_access_restrict_ssm']).to eq ['Restricted until 2018.']
      end

      it 'it gets access restrict from parent' do
        expect(parent_access_restrict_component['parent_ssm']).to eq %w[aoa271]
        expect(parent_access_restrict_component['parent_access_restrict_ssm']).to eq ['No restrictions on access.']
      end

      it 'parent access terms' do
        expect(access_terms_component['parent_ssm']).to eq %w[aoa271]
        expect(access_terms_component['parent_access_terms_ssm']).to eq ["Copyright was transferred to the public domain. Contact the Reference Staff for details\n        regarding rights."]
      end
    end
  end
end
