# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ArclightHelper, type: :helper do
  describe '#parents_to_links' do
    let(:document) do
      SolrDocument.new(
        parent_ssm: %w[def ghi],
        parent_unittitles_ssm: %w[DEF GHI],
        ead_ssi: 'abc123'
      )
    end

    it 'converts "parents" from SolrDocument to links' do
      expect(helper.parents_to_links(document)).to include 'DEF'
      expect(helper.parents_to_links(document)).to include solr_document_path('abc123def')
      expect(helper.parents_to_links(document)).to include 'GHI'
      expect(helper.parents_to_links(document)).to include solr_document_path('abc123ghi')
    end
    it 'properly delimited' do
      expect(helper.parents_to_links(document)).to include '»'
      expect(helper.parents_to_links(SolrDocument.new)).not_to include '»'
    end
  end
end
