# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Indexing Custom Component', type: :feature do
  let(:components) do # an Array<Arclight::CustomComponent>
    options = { component: Arclight::CustomComponent }
    ENV['SOLR_URL'] = Blacklight.connection_config[:url]
    indexer = SolrEad::Indexer.new(options) # `initialize` requires a solr connection

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
      expect(doc['level_sim'].first).to eq 'Mixed File'

      doc = components[3].to_solr
      expect(doc['level_ssm'].first).to eq 'otherlevel'
      expect(doc['level_sim'].first).to eq 'Other'
    end
  end
end
