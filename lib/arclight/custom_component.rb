# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom component indexing code
  class CustomComponent < SolrEad::Component
    include Arclight::SharedIndexingBehavior
    use_terminology SolrEad::Component

    extend_terminology do |t|
      t.unitid(path: 'c/did/unitid', index_as: %i[displayable])
      t.creator(path: "c/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable])
      t.otherlevel(path: 'c/@otherlevel', index_as: %i[displayable])

      # overrides of solr_ead to get different `index_as` properties
      t.ref_(path: '/c/@id', index_as: %i[displayable])
      t.level(path: 'c/@level', index_as: %i[displayable]) # machine-readable for string `level_ssm`
      t.extent(path: 'c/did/physdesc/extent', index_as: %i[displayable])
      t.unitdate(path: 'c/did/unitdate', index_as: %i[displayable])
      t.accessrestrict(path: 'c/accessrestrict/p', index_as: %i[displayable])
      t.scopecontent(path: 'c/scopecontent/p', index_as: %i[displayable])
      t.normal_unit_dates(path: 'c/did/unitdate/@normal')
    end

    def to_solr(solr_doc = {})
      super
      Solrizer.insert_field(solr_doc, 'level', formatted_level, :facetable) # human-readable for facet `level_sim`
      Solrizer.insert_field(solr_doc, 'date_range', formatted_unitdate_for_range, :facetable)
      solr_doc
    end

    private

    # @see http://eadiva.com/2/c/
    def formatted_level
      # terminology definitions for level yield Arrays and in this case single values
      # TODO: OM changes the behavior of `level = level.first` such that it always returns `nil`
      #       so need our own local variable here
      actual_level = level.first.to_s if level.respond_to? :first

      if actual_level == 'otherlevel'
        alternative_level = otherlevel.first.to_s if otherlevel.respond_to? :first
        alternative_level.present? ? alternative_level : 'Other'
      elsif actual_level.present?
        actual_level.capitalize
      end
    end
  end
end
