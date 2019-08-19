# frozen_string_literal: true

require 'spec_helper'

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
    describe 'components' do
      let(:first_component) { result['components'].first }

      it 'id' do
        expect(first_component).to include 'id' => ['a0011-xmlaspace_ref6_lx4']
      end
      it 'repository' do
        %w[repository_sim repository_ssm].each do |field|
          expect(first_component[field]).to include 'Stanford University Libraries. Special Collections and University Archives'
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
end
