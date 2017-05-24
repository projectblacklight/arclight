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
        node = xml.at_xpath('//c')
        fields = indexer.additional_component_fields(node)
        expect(fields['parent_ssi']).to eq 'aoa271'
        expect(fields['parent_ssm']).to eq ['aoa271']
        expect(fields['parent_unittitles_ssm']).to eq ['Alpha Omega Alpha Archives, 1894-1992']
      end
    end
  end

  describe '#add_count_of_child_compontents' do
    it 'adds the number of direct children' do
      node = xml.at_xpath('//c[@id="aspace_563a320bb37d24a9e1e6f7bf95b52671"]')
      fields = indexer.additional_component_fields(node)
      expect(fields['child_component_count_isim']).to eq 25
    end

    it 'returns zero when the child has no components' do
      node = xml.at_xpath('//c[@id="aspace_843e8f9f22bac69872d0802d6fffbb04"]')
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

  describe '#add_self_or_parents_restrictions' do
    it 'adds first restrictions found in self, parents, or collection' do
      node = xml.xpath('//c[@id="aspace_72f14d6c32e142baa3eeafdb6e4d69be"]').first
      fields = indexer.additional_component_fields(node)
      expect(fields['parent_access_restrict_ssm']).to eq ['No restrictions on access.']
    end
  end

  describe '#add_self_or_parents_terms' do
    it 'adds first user terms found in self, parents, or collection' do
      node = xml.xpath('//c[@id="aspace_72f14d6c32e142baa3eeafdb6e4d69be"]').first
      fields = indexer.additional_component_fields(node)
      expect(fields['parent_access_terms_ssm']).to eq ['Original photographs must be handled using gloves.']
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
