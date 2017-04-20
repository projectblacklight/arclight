# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom document indexing code
  class CustomDocument < SolrEad::Document
    use_terminology SolrEad::Document

    extend_terminology do |t|
      t.unitid(path: 'archdesc/did/unitid', index_as: %i[displayable])
      t.repository(path: 'archdesc/did/repository/corpname/text() | archdesc/did/repository/name/text()', index_as: %i[displayable facetable])
      t.creator(path: "archdesc/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable])
      t.prefercite(path: 'archdesc/prefercite/p', index_as: %i[displayable])

      # overrides of solr_ead to get different `index_as` properties
      t.extent(path: 'archdesc/did/physdesc/extent', index_as: %i[displayable])
      t.unitdate(path: 'archdesc/did/unitdate', index_as: %i[displayable])
      t.accessrestrict(path: 'archdesc/accessrestrict/p', index_as: %i[displayable])
      t.scopecontent(path: 'archdesc/scopecontent/p', index_as: %i[displayable])
      t.userestrict(path: 'archdesc/userestrict/p', index_as: %i[displayable])
      t.abstract(path: 'archdesc/did/abstract', index_as: %i[displayable])
    end

    def to_solr(solr_doc = {})
      super
      Solrizer.insert_field(solr_doc, 'level', 'collection', :displayable) # machine-readable
      Solrizer.insert_field(solr_doc, 'level', 'Collection', :facetable) # human-readable
      Solrizer.insert_field(solr_doc, 'names', names, :facetable)
      solr_doc
    end

    private

    def names
      [corpname, famname, name, persname].flatten.compact.uniq - repository
    end
  end
end
