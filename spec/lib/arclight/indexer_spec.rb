# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Indexer do
  ENV['SOLR_URL'] = Blacklight.connection_config[:url]
  subject(:indexer) { described_class.new } # `initialize` requires a solr connection

  let(:xml) do
    data = Nokogiri::XML(
      File.open('spec/fixtures/ead/nlm/alphaomegaalpha.xml').read
    )
    data.remove_namespaces!
    data
  end

  it 'is a wrapper around SolrEad::Indexer' do
    expect(indexer).to be_kind_of SolrEad::Indexer
  end

  describe '#add_collection_context_to_parent_fields' do
    context 'collection context' do
      it 'are appended to the existing parent fields' do
        node = xml.xpath('//c').first
        fields = indexer.additional_component_fields(node)
        expect(fields['parent_ssi']).to eq 'aoa271'
        expect(fields['parent_ssm']).to eq ['aoa271']
        expect(fields['parent_unittitles_ssm']).to eq ['Alpha Omega Alpha Archives']
      end
    end
  end

  describe '#add_count_of_child_compontents' do
    it 'adds the number of direct children' do
      node = xml.xpath('//c[@id="aspace_563a320bb37d24a9e1e6f7bf95b52671"]').first
      fields = indexer.additional_component_fields(node)
      expect(fields['child_component_count_isim']).to eq 25
    end

    it 'retunrs zero when the child has no components' do
      node = xml.xpath('//c[@id="aspace_843e8f9f22bac69872d0802d6fffbb04"]').first
      fields = indexer.additional_component_fields(node)
      expect(fields['child_component_count_isim']).to eq 0
    end
  end

  describe '#add_collection_creator_to_component' do
    it 'adds the creator of the collection to a stored non-indexed/faceted field' do
      node = xml.xpath('//c[@id="aspace_563a320bb37d24a9e1e6f7bf95b52671"]').first
      fields = indexer.additional_component_fields(node)
      expect(fields['creator_ssim']).to be_nil
      expect(fields['collection_creator_ssm']).to eq ['Alpha Omega Alpha']
    end
  end

  describe 'delete_all' do
    before do
      expect(indexer).to receive_messages(solr: solr_client)
    end

    let(:solr_client) { instance_spy('SolrClient') }

    it 'sends the delete all query to solr and commits' do
      indexer.delete_all
      expect(solr_client).to have_received(:delete_by_query).with('*:*')
      expect(solr_client).to have_receive(:commit)
    end
  end
end
