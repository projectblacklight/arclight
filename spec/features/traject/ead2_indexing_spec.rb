require 'spec_helper'

describe 'EAD 2 traject indexing' do
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

  describe 'solr fields' do
    it 'id' do
      expect(result['id'].first).to eq 'a0011-xml'
    end
    it 'title' do
      ['title_ssm', 'title_teim'].each do |field|
        expect(result[field]).to include 'Stanford University student life photograph album'
      end
    end
    describe 'components' do
      it 'id' do
        expect(result['components'].first).to include 'id' => ['a0011-xmlaspace_ref6_lx4']
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
    
  end
end
