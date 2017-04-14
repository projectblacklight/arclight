# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom component indexing code
  class CustomComponent < SolrEad::Component
    use_terminology SolrEad::Component

    extend_terminology do |t|
      t.unitid(path: 'c/did/unitid', index_as: %i[displayable])
      t.creator(path: "c/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable])

      # overrides of solr_ead to get different `index_as` properties
      t.ref_(path: '/c/@id', index_as: %i[displayable])
      t.level(path: 'c/@level', index_as: %i[displayable facetable])
      t.extent(path: 'c/did/physdesc/extent', index_as: %i[displayable])
      t.unitdate(path: 'c/did/unitdate[not(@type)]', index_as: %i[displayable])
      t.accessrestrict(path: 'c/accessrestrict/p', index_as: %i[displayable])
      t.scopecontent(path: 'c/scopecontent/p', index_as: %i[displayable])
    end
  end
end
