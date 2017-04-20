# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom document indexing code
  class CustomDocument < SolrEad::Document
    include Arclight::SharedIndexingBehavior
    use_terminology SolrEad::Document

    extend_terminology do |t|
      t.unitid(path: 'archdesc/did/unitid', index_as: %i[displayable])
      t.repository(path: 'archdesc/did/repository/corpname/text() | archdesc/did/repository/name/text()', index_as: %i[displayable facetable])
      t.creator(path: "archdesc/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable])
      t.prefercite(path: 'archdesc/prefercite/p', index_as: %i[displayable])
      t.function(path: 'archdesc/controlaccess/function/text()', index_as: %i[displayable facetable])
      t.occupation(path: 'archdesc/controlaccess/occupation/text()', index_as: %i[displayable facetable])

      # overrides of solr_ead to get different `index_as` properties
      t.extent(path: 'archdesc/did/physdesc/extent', index_as: %i[displayable])
      t.unitdate(path: 'archdesc/did/unitdate', index_as: %i[displayable])
      t.accessrestrict(path: 'archdesc/accessrestrict/p', index_as: %i[displayable])
      t.scopecontent(path: 'archdesc/scopecontent/p', index_as: %i[displayable])
      t.userestrict(path: 'archdesc/userestrict/p', index_as: %i[displayable])
      t.abstract(path: 'archdesc/did/abstract', index_as: %i[displayable])
      t.normal_unit_dates(path: 'archdesc/did/unitdate/@normal')
    end

    def to_solr(solr_doc = {})
      super
      Solrizer.insert_field(solr_doc, 'level', 'collection', :displayable) # machine-readable
      Solrizer.insert_field(solr_doc, 'level', 'Collection', :facetable) # human-readable
      Solrizer.insert_field(solr_doc, 'names', names, :facetable)
      Solrizer.insert_field(solr_doc, 'date_range', formatted_unitdate_for_range, :facetable)
      Solrizer.insert_field(solr_doc, 'access_subjects', access_subjects, :facetable)
      solr_doc
    end

    private

    def names
      [corpname, famname, name, persname].flatten.compact.uniq - repository
    end

    # Combine subjets into one group from:
    #  <controlaccess/><subject></subject>
    #  <controlaccess/><function></function>
    #  <controlaccess/><genreform></genreform>
    #  <controlaccess/><occupation></occupation>
    def access_subjects
      subjects = search("//*[local-name()='subject' or local-name()='function' or local-name() = 'occupation' or local-name() = 'genreform']").to_a
      clean_facets_array(subjects.flatten.map(&:text))
    end

    # Return a cleaned array of facets without marc subfields
    #
    # E.g. clean_facets_array(['FacetValue1 |z FacetValue2','FacetValue3']) => ['FacetValue1 -- FacetValue2', 'FacetValue3']
    def clean_facets_array(facets_array)
      Array(facets_array).map { |text| fix_subfield_demarcators(text) }.compact.uniq
    end

    # Replace MARC style subfield demarcators
    #
    # Usage: fix_subfield_demarcators("Subject 1 |z Sub-Subject 2") => "Subject 1 -- Sub-Subject 2"
    def fix_subfield_demarcators(value)
      value.gsub(/\|\w{1}/, '--')
    end

    # Wrap OM's find_by_xpath for convenience
    def search(path)
      find_by_xpath(path) # rubocop:disable DynamicFindBy
    end
  end
end
