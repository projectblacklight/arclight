# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom document indexing code
  class CustomDocument < SolrEad::Document
    use_terminology SolrEad::Document

    extend_terminology do |t|
      t.unitid(path: 'archdesc/did/unitid', index_as: %i[displayable])
      t.repository(path: 'archdesc/did/repository/*/text()', index_as: %i[displayable facetable])
      t.creator(path: "archdesc/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable])

      # overrides of solr_ead to get different `index_as` properties
      t.extent(path: 'archdesc/did/physdesc/extent', index_as: %i[displayable])
      t.unitdate(path: 'archdesc/did/unitdate[not(@type)]', index_as: %i[displayable])
      t.accessrestrict(path: 'archdesc/accessrestrict/p', index_as: %i[displayable])
      t.scopecontent(path: 'archdesc/scopecontent/p', index_as: %i[displayable])
    end
  end
end
