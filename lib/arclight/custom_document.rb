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
      t.creator(path: "archdesc/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable symbol])
      t.prefercite(path: 'archdesc/prefercite/p', index_as: %i[displayable])
      t.function(path: 'archdesc/controlaccess/function/text()', index_as: %i[displayable facetable])
      t.occupation(path: 'archdesc/controlaccess/occupation/text()', index_as: %i[displayable facetable])
      t.otherfindaid(path: 'archdesc/otherfindaid/p', index_as: %i[displayable])

      # overrides of solr_ead to get different `index_as` properties
      t.extent(path: 'archdesc/did/physdesc/extent', index_as: %i[displayable])
      t.unitdate(path: 'archdesc/did/unitdate', index_as: %i[displayable])
      t.accessrestrict(path: 'archdesc/accessrestrict/p', index_as: %i[displayable])
      t.scopecontent(path: 'archdesc/scopecontent/p', index_as: %i[displayable])
      t.userestrict(path: 'archdesc/userestrict/p', index_as: %i[displayable])
      t.abstract(path: 'archdesc/did/abstract', index_as: %i[displayable])
      t.normal_unit_dates(path: 'archdesc/did/unitdate/@normal')
      t.bioghist(path: 'archdesc/bioghist/p', index_as: %i[displayable])
      t.arrangement(path: 'archdesc/arrangement/p', index_as: %i[displayable])
      t.relatedmaterial(path: 'archdesc/relatedmaterial/p', index_as: %i[displayable])
      t.separatedmaterial(path: 'archdesc/separatedmaterial/p', index_as: %i[displayable])
      t.altformavail(path: 'archdesc/altformavail/p', index_as: %i[displayable])
      t.originalsloc(path: 'archdesc/originalsloc/p', index_as: %i[displayable])
      t.acqinfo(path: 'archdesc/acqinfo/p', index_as: %i[displayable])
      t.appraisal(path: 'archdesc/appraisal/p', index_as: %i[displayable])
      t.custodhist(path: 'archdesc/custodhist/p', index_as: %i[displayable])
      t.processinfo(path: 'archdesc/processinfo/p', index_as: %i[displayable])
    end

    def to_solr(solr_doc = {})
      super
      solr_doc['id'] = eadid.first.strip.tr('.', '-')
      Solrizer.insert_field(solr_doc, 'level', 'collection', :displayable) # machine-readable
      Solrizer.insert_field(solr_doc, 'level', 'Collection', :facetable) # human-readable
      Solrizer.insert_field(solr_doc, 'names', names, :facetable)
      Solrizer.insert_field(solr_doc, 'date_range', formatted_unitdate_for_range, :facetable)
      Solrizer.insert_field(solr_doc, 'access_subjects', access_subjects, :facetable)
      Solrizer.insert_field(solr_doc, 'all_subjects', all_subjects, :symbol)
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
      subjects_array(%w[subject function occupation genreform], parent: 'archdesc')
    end

    def all_subjects
      subjects_array(%w[corpname famname function genreform geogname occupation persname subject title], parent: 'archdesc')
    end
  end
end
