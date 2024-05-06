# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Parents do
  let(:document) do
    SolrDocument.new(
      parent_ids_ssim: %w[abc123 abc123_def abc123_ghi],
      parent_unittitles_ssm: %w[ABC123 DEF GHI],
      ead_ssi: 'abc123',
      parent_levels_ssm: %w[collection]
    )
  end

  let(:legacy_parent_ids_doc) do
    SolrDocument.new(
      parent_ssim: %w[abc123 def ghi],
      parent_unittitles_ssm: %w[ABC123 DEF GHI],
      ead_ssi: 'abc123',
      parent_levels_ssm: %w[collection]
    )
  end

  let(:dot_eadid_doc) do
    SolrDocument.new(
      parent_ids_ssim: %w[abc123-xml abc123-xml_def abc123-xml_ghi],
      parent_unittitles_ssm: %w[ABC123 DEF GHI],
      ead_ssi: 'abc123.xml',
      parent_levels_ssm: %w[collection]
    )
  end

  let(:empty_document) { SolrDocument.new }
  let(:good_instance) { described_class.from_solr_document(document) }
  let(:dot_eadid_instance) { described_class.from_solr_document(dot_eadid_doc) }
  let(:legacy_parent_ids_instance) { described_class.from_solr_document(legacy_parent_ids_doc) }

  describe '.from_solr_document' do
    context 'with good data' do
      it 'returns an instance of itself' do
        expect(good_instance).to be_an described_class
      end

      it 'values are appropriately set' do
        expect(good_instance.ids).to eq %w[abc123 abc123_def abc123_ghi]
        expect(good_instance.legacy_ids).to be_empty
        expect(good_instance.labels).to eq %w[ABC123 DEF GHI]
        expect(good_instance.eadid).to eq 'abc123'
        expect(good_instance.levels).to eq %w[collection]
      end

      it 'cleans up the eadid properly by replacing dots with dashes' do
        expect(dot_eadid_instance.eadid).to eq 'abc123-xml'
      end
    end

    context 'with legacy parent_ssim data' do
      it 'id values are appropriately set' do
        expect(legacy_parent_ids_instance.ids).to be_empty
        expect(legacy_parent_ids_instance.legacy_ids).to eq %w[abc123 abc123def abc123ghi]
      end
    end

    context 'with no data' do
      it 'returns an instance of itself' do
        expect(described_class.from_solr_document(empty_document)).to be_an described_class
      end
    end
  end

  describe '#as_parents' do
    context 'with good data' do
      it 'returns an array' do
        expect(good_instance.as_parents).to be_an Array
      end

      it 'the array length equals ids length' do
        expect(good_instance.as_parents.length).to eq good_instance.ids.length
      end

      it 'each item in array is an Arclight::Parent' do
        expect(good_instance.as_parents).to all(be_an(Arclight::Parent))
      end

      it 'the containing parents have the correct data' do
        expect(good_instance.as_parents.first.id).to eq 'abc123'
        expect(good_instance.as_parents.first.label).to eq 'ABC123'
        expect(good_instance.as_parents.first.eadid).to eq 'abc123'
        expect(good_instance.as_parents.first.level).to eq 'collection'
      end
    end

    context 'with legacy parent_ssim data' do
      it 'the containing parents have the correct data' do
        expect(legacy_parent_ids_instance.as_parents.first.id).to eq 'abc123'
        expect(legacy_parent_ids_instance.as_parents.last.id).to eq 'abc123ghi'
      end
    end

    context 'with no data' do
      it 'returns an empty array' do
        expect(described_class.new(ids: [], legacy_ids: [], labels: [], eadid: '', levels: '').as_parents).to eq []
      end
    end
  end
end
