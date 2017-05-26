# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom document indexing code
  class CustomDocument < SolrEad::Document
    extend Arclight::SharedTerminologyBehavior
    include Arclight::SharedIndexingBehavior
    use_terminology SolrEad::Document

    # we extend the terminology to provide additional fields and/or indexing strategies
    # than `solr_ead` provides as-is. in many cases we're doing redundant indexing, but
    # we're trying to modify the `solr_ead` gem as little as possible
    extend_terminology do |t|
      # facets
      t.repository(path: 'archdesc/did/repository/corpname/text() | archdesc/did/repository/name/text()', index_as: %i[displayable facetable])
      t.creator(path: "archdesc/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable symbol])
      t.creator_persname(path: "archdesc/did/origination[@label='creator']/persname/text()", index_as: %i[displayable facetable symbol])
      t.creator_corpname(path: "archdesc/did/origination[@label='creator']/corpname/text()", index_as: %i[displayable facetable symbol])
      t.creator_famname(path: "archdesc/did/origination[@label='creator']/famname/text()", index_as: %i[displayable facetable symbol])
      t.function(path: 'archdesc/controlaccess/function/text()', index_as: %i[displayable facetable])
      t.occupation(path: 'archdesc/controlaccess/occupation/text()', index_as: %i[displayable facetable])
      t.places(path: 'archdesc/controlaccess/geogname/text()', index_as: %i[displayable facetable symbol])

      add_unitid(t, 'archdesc/')
      add_extent(t, 'archdesc/')
      add_dates(t, 'archdesc/')
      add_searchable_notes(t, 'archdesc/')
    end

    def to_solr(solr_doc = {})
      super
      solr_doc['id'] = Arclight::NormalizedId.new(eadid.first).to_s
      arclight_field_definitions.each do |field|
        # we want to use `set_field` rather than `insert_field` since we may be overriding fields
        Solrizer.set_field(solr_doc, field[:name], field[:value], field[:index_as])
      end

      add_date_ranges(solr_doc)
      add_digital_content(prefix: 'ead/archdesc', solr_doc: solr_doc)
      add_normalized_titles(solr_doc)

      solr_doc
    end

    private

    def add_normalized_titles(solr_doc)
      title = add_normalized_title(solr_doc)
      Solrizer.set_field(solr_doc, 'collection', title, :facetable)
      Solrizer.set_field(solr_doc, 'collection', title, :displayable)
    end

    def arclight_field_definitions
      [
        { name: 'level', value: 'collection', index_as: :displayable },
        { name: 'level', value: 'Collection', index_as: :facetable },
        { name: 'names', value: names, index_as: :symbol },
        { name: 'access_subjects', value: access_subjects, index_as: :symbol },
        { name: 'creators', value: creators, index_as: :symbol },
        { name: 'has_online_content', value: online_content?, index_as: :symbol },
        { name: 'repository', value: repository_as_configured(repository), index_as: :displayable },
        { name: 'repository', value: repository_as_configured(repository), index_as: :facetable },
        { name: 'names_coll', value: names_coll, index_as: :symbol }
      ]
    end

    def names
      [corpname, famname, name, persname].flatten.compact.uniq - repository
    end

    def names_coll
      names_array(%w[corpname famname name persname], parent: 'archdesc')
    end

    def creators
      [creator_persname, creator_corpname, creator_famname].flatten.compact.uniq - repository
    end

    # Combine subjets into one group from
    #  <controlaccess/><subject></subject>
    #  <controlaccess/><function></function>
    #  <controlaccess/><genreform></genreform>
    #  <controlaccess/><occupation></occupation>
    def access_subjects
      subjects_array(%w[subject function occupation genreform], parent: 'archdesc')
    end
  end
end
