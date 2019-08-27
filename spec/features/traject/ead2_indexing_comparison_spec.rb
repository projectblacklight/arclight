# frozen_string_literal: true

require 'spec_helper'

describe 'EAD 2 traject indexing', type: :feature do
  describe 'Collection document' do
    let(:result) do
      indexer.map_record(record)
    end

    let(:solr_ead_result) do
      Arclight::CustomDocument.from_xml(fixture_file).to_solr
    end

    let(:indexer) do
      Traject::Indexer::NokogiriIndexer.new.tap do |i|
        i.load_config_file(Arclight::Engine.root.join('lib/arclight/traject/ead2_config.rb'))
      end
    end
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'sul-spec', 'a0011.xml')
    end
    let(:fixture_file) do
      File.read(fixture_path)
    end
    let(:nokogiri_reader) do
      Traject::NokogiriReader.new(fixture_file.to_s, {})
    end
    let(:records) do
      nokogiri_reader.to_a
    end
    let(:record) do
      records.first
    end

    it 'the outputs should be the same' do
      pending('traject work still in progress')
      expect(result).to eq solr_ead_result
    end
  end
end
