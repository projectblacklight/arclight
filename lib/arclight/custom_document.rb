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
      t.creator_persname(path: "archdesc/did/origination[@label='creator']/persname/text()", index_as: %i[displayable facetable symbol])
      t.creator_corpname(path: "archdesc/did/origination[@label='creator']/corpname/text()", index_as: %i[displayable facetable symbol])
      t.creator_famname(path: "archdesc/did/origination[@label='creator']/famname/text()", index_as: %i[displayable facetable symbol])
      t.prefercite(path: 'archdesc/prefercite/p', index_as: %i[displayable])
      t.function(path: 'archdesc/controlaccess/function/text()', index_as: %i[displayable facetable])
      t.occupation(path: 'archdesc/controlaccess/occupation/text()', index_as: %i[displayable facetable])
      t.places(path: 'archdesc/controlaccess/geogname/text()', index_as: %i[displayable facetable symbol])
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
      arclight_field_definitions.each do |field|
        # we want to use `set_field` rather than `insert_field` since we may be overriding fields
        Solrizer.set_field(solr_doc, field[:name], field[:value], field[:index_as])
      end
      solr_doc
    end

    private

    # rubocop: disable Metrics/MethodLength
    def arclight_field_definitions
      [
        { name: 'level', value: 'collection', index_as: :displayable },
        { name: 'level', value: 'Collection', index_as: :facetable },
        { name: 'names', value: names, index_as: :symbol },
        { name: 'date_range', value: formatted_unitdate_for_range, index_as: :facetable },
        { name: 'access_subjects', value: access_subjects, index_as: :symbol },
        { name: 'creators', value: creators, index_as: :symbol },
        { name: 'has_online_content', value: online_content?, index_as: :displayable },
        { name: 'repository', value: repository_as_configured(repository), index_as: :displayable },
        { name: 'repository', value: repository_as_configured(repository), index_as: :facetable }
      ]
    end
    # rubocop: enable Metrics/MethodLength

    def names
      [corpname, famname, name, persname].flatten.compact.uniq - repository
    end

    def creators
      [creator_persname, creator_corpname, creator_famname].flatten.compact.uniq - repository
    end

    # Combine subjets into one group from:
    #  <controlaccess/><subject></subject>
    #  <controlaccess/><function></function>
    #  <controlaccess/><genreform></genreform>
    #  <controlaccess/><occupation></occupation>
    def access_subjects
      subjects_array(%w[subject function occupation genreform], parent: 'archdesc')
    end

    def online_content?
      search('//dao[@href]').present?
    end
  end
end
