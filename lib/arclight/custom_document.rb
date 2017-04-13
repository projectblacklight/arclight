# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom document indexing code
  class CustomDocument < SolrEad::Document
    use_terminology SolrEad::Document

    extend_terminology do |t|
      t.unitid(path: 'archdesc/did/unitid', index_as: [:displayable])
      t.repository(path: 'archdesc/did/repository/*/text()', index_as: %i[displayable facetable])
      t.creator(path: "archdesc/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable])
    end
  end
end
