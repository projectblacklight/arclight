# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom component indexing code
  class CustomComponent < SolrEad::Component
    use_terminology SolrEad::Component

    extend_terminology do |t|
      t.unitid(path: 'c/did/unitid', index_as: [:displayable])
      t.creator(path: "c/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable])
    end
  end
end
