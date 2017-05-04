# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Indexing Custom Component', type: :feature do
  let(:components) do # an Array<Arclight::CustomComponent>
    options = { component: Arclight::CustomComponent }
    ENV['SOLR_URL'] = Blacklight.connection_config[:url]
    indexer = Arclight::Indexer.new(options) # `initialize` requires a solr connection

    components = []
    indexer.components('spec/fixtures/ead/alphaomegaalpha.xml').each do |node|
      components << indexer.send(:om_component_from_node, node) # private method :(
    end
    components
  end

  context 'solrizer' do
    it '#level' do
      doc = components[0].to_solr
      expect(doc['level_ssm'].first).to eq 'series'
      expect(doc['level_sim'].first).to eq 'Series'

      doc = components[2].to_solr
      expect(doc['level_ssm'].first).to eq 'otherlevel'
      expect(doc['level_sim'].first).to eq 'Binder'

      doc = components[3].to_solr
      expect(doc['level_ssm'].first).to eq 'otherlevel'
      expect(doc['level_sim'].first).to eq 'Other'
    end

    describe '#access_subject' do
      it 'has the subjects for the given compontent' do
        doc1 = components[26].to_solr
        doc2 = components[27].to_solr

        expect(doc1['access_subjects_sim']).to eq ['Minutes']
        expect(doc2['access_subjects_sim']).to eq ['Records']
      end
    end

    describe '#date_range' do
      it 'includes an array of all the years in a particular unit-date range described in YYYY/YYYY format' do
        doc = components[0].to_solr

        date_range_field = doc['date_range_sim']
        expect(doc['unitdate_ssm']).to eq ['1902-1976'] # the field the range is derived from
        expect(date_range_field).to be_an Array
        expect(date_range_field.length).to eq 75
        expect(date_range_field.first).to eq '1902'
        expect(date_range_field.last).to eq '1976'
      end

      it 'is nil for non normal dates' do
        doc = components[1].to_solr

        date_range_field = doc['date_range_sim']
        expect(doc['unitdate_ssm']).to eq ['n.d.']
        expect(date_range_field).to be_nil
      end

      it 'handles normal unitdates formatted as YYYY/YYYY when the years are the same' do
        doc = components[2].to_solr

        date_range_field = doc['date_range_sim']
        expect(doc['unitdate_ssm']).to eq ['c.1902']
        expect(date_range_field).to eq ['1902']
      end

      it 'handles normal unitdates formatted as YYYY' do
        doc = components[6].to_solr

        date_range_field = doc['date_range_sim']
        expect(doc['unitdate_ssm']).to eq ['1904']
        expect(date_range_field).to eq ['1904']
      end
    end

    context '#repository_as_configured' do
      let(:component) { components[0] }

      before do
        ENV['REPOSITORY_ID'] = nil
        ENV['REPOSITORY_FILE'] = 'spec/fixtures/config/repositories.yml'
      end

      after do # ensure we reset these otherwise other tests will fail
        ENV['REPOSITORY_ID'] = nil
        ENV['REPOSITORY_FILE'] = nil
      end

      it '#repository' do
        expect(component.repository_as_configured('foobar')).to eq 'foobar'
      end

      context 'with repository configuration' do
        it 'with valid id' do
          ENV['REPOSITORY_ID'] = 'US-CaS-BVSC'
          expect(component.repository_as_configured('XXX')).to eq 'US CaS Badger Vine Special Collections'
        end

        it 'with an invalid id' do
          ENV['REPOSITORY_ID'] = 'NOT FOUND'
          expect { component.repository_as_configured('XXX') }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
