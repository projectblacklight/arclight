# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Indexer do
  ENV['SOLR_URL'] = Blacklight.connection_config[:url]
  subject(:indexer) { described_class.new } # `initialize` requires a solr connection

  let(:xml) do
    data = Nokogiri::XML(
      File.open('spec/fixtures/ead/alphaomegaalpha.xml').read
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
end
