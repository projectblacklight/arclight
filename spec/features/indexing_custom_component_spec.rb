# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Indexing Custom Component', type: :feature do
  let(:components) do # an Array<Arclight::CustomComponent>
    options = { component: Arclight::CustomComponent }
    ENV['SOLR_URL'] = Blacklight.connection_config[:url]
    indexer = Arclight::Indexer.new(options) # `initialize` requires a solr connection

    components = []
    indexer.components('spec/fixtures/ead/nlm/alphaomegaalpha.xml').each do |node|
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
        doc1 = components.find do |c|
          c.to_solr['ref_ssm'] == ['aspace_81c806b82a14c3c79d395bbd383b886f']
        end.to_solr
        doc2 = components.find do |c|
          c.to_solr['ref_ssm'] == ['aspace_01daa89087641f7fc9dbd7a10d3f2da9']
        end.to_solr

        expect(doc1['access_subjects_sim']).to eq ['Minutes']
        expect(doc2['access_subjects_sim']).to eq ['Records']
      end
    end

    describe '#containers' do
      it 'has containers for the given component' do
        doc1 = components[1].to_solr
        expect(doc1['containers_ssim']).to eq ['box 1', 'folder 1']
      end
    end

    describe '#normalize_title and date' do
      it 'has both inclusive and bulk' do
        doc = components[0].to_solr
        expect(doc['normalized_date_ssm']).to eq ['1902-1976, bulk 1975-1976']
        expect(doc['normalized_title_ssm']).to eq ['Series I: Administrative Records, 1902-1976, bulk 1975-1976']
      end

      it 'has no normal attribute' do
        doc = components[1].to_solr
        expect(doc['normalized_date_ssm']).to eq ['n.d.']
        expect(doc['normalized_title_ssm'].first).to match(/^"A brief account of the .*, n\.d\./m)
      end

      it 'uses circa' do
        doc = components[2].to_solr
        expect(doc['normalized_date_ssm']).to eq ['c.1902']
        expect(doc['normalized_title_ssm']).to eq ['Statements of purpose, c.1902']
      end

      it 'uses inclusive YYYY' do
        doc = components[6].to_solr
        expect(doc['normalized_date_ssm']).to eq ['1904']
        expect(doc['normalized_title_ssm'].first).to match(/^The constitution of the .*, 1904/m)
      end

      it 'handles missing date specifications' do
        doc = components.find do |c|
          c.to_solr['ref_ssm'] == ['aspace_01daa89087641f7fc9dbd7a10d3f2da9']
        end.to_solr
        expect(doc['normalized_date_ssm'].first).to be_nil
      end

      it 'handles n.d. with a date for non-best practice unitdate attributes' do
        doc = components.find do |c|
          c.to_solr['ref_ssm'] == ['aspace_a8b5c3a57013462581d0e807241fcf93']
        end.to_solr
        expect(doc['normalized_date_ssm']).to eq ['1904, n.d.']
      end
    end

    describe '#parents' do
      it 'has a reference' do
        doc = components[1].to_solr
        expect(doc['ref_ssi']).to eq 'aspace_843e8f9f22bac69872d0802d6fffbb04'
        expect(doc['ref_ssm']).to eq ['aspace_843e8f9f22bac69872d0802d6fffbb04']
      end
      it 'should check on the entire parents ids, etc. but we need to integrate solr_ead_indexer_ext here'
    end

    describe '#date_range' do
      it 'includes an array of all the years in a particular unit-date range described in YYYY/YYYY format' do
        doc = components[0].to_solr
        date_range_field = doc['date_range_sim']
        expect(date_range_field).to be_an Array
        expect(date_range_field.length).to eq 75
        expect(date_range_field.first).to eq '1902'
        expect(date_range_field.last).to eq '1976'
      end

      it 'is nil for non normal dates' do
        doc = components[1].to_solr

        date_range_field = doc['date_range_sim']
        expect(date_range_field).to be_nil
      end

      it 'handles normal unitdates formatted as YYYY/YYYY when the years are the same' do
        doc = components[2].to_solr

        date_range_field = doc['date_range_sim']
        expect(date_range_field).to eq ['1902']
      end

      it 'handles normal unitdates formatted as YYYY' do
        doc = components[6].to_solr

        date_range_field = doc['date_range_sim']
        expect(date_range_field).to eq ['1904']
      end
    end

    describe '#add_digital_content' do
      it 'adds digital object json' do
        doc = components.find do |c|
          c.to_solr['ref_ssm'] == ['aspace_843e8f9f22bac69872d0802d6fffbb04']
        end.to_solr

        digital_objects = doc['digital_objects_ssm']
        expect(digital_objects.length).to eq 2
        digital_objects.each do |object|
          json = JSON.parse(object)
          expect(json).to be_a Hash
          expect(json).to have_key 'label'
          expect(json).to have_key 'href'
        end
      end

      it 'does not include the field of there is no dao for the component' do
        doc = components[2].to_solr
        expect(doc).not_to include 'digital_objects_ssm'
      end
    end

    context '#repository_as_configured' do
      let(:component) { components[0] }

      before do
        ENV['REPOSITORY_ID'] = nil
      end

      after do # ensure we reset these otherwise other tests will fail
        ENV['REPOSITORY_ID'] = nil
      end

      it '#repository' do
        expect(component.repository_as_configured('foobar')).to eq 'foobar'
      end

      context 'with repository configuration' do
        it 'with valid id' do
          ENV['REPOSITORY_ID'] = 'nlm'
          expect(component.repository_as_configured('XXX')).to eq(
            'National Library of Medicine. History of Medicine Division'
          )
        end

        it 'with an invalid id' do
          ENV['REPOSITORY_ID'] = 'NOT FOUND'
          expect { component.repository_as_configured('XXX') }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
