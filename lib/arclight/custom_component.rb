# frozen_string_literal: true

module Arclight
  ##
  # An Arclight custom component indexing code
  class CustomComponent < SolrEad::Component
    extend Arclight::SharedTerminologyBehavior
    include Arclight::SharedIndexingBehavior
    use_terminology SolrEad::Component

    # we extend the terminology to provide additional fields and/or indexing strategies
    # than `solr_ead` provides as-is. in many cases we're doing redundant indexing, but
    # we're trying to modify the `solr_ead` gem as little as possible
    extend_terminology do |t|
      # identifiers
      t.level(path: 'c/@level', index_as: %i[displayable]) # machine-readable for string `level_ssm`
      t.otherlevel(path: 'c/@otherlevel', index_as: %i[displayable])
      t.ref_(path: '/c/@id', index_as: %i[displayable])

      # facets
      t.creator(path: "c/did/origination[@label='creator']/*/text()", index_as: %i[displayable facetable])

      add_unitid(t, 'c/')
      add_extent(t, 'c/')
      add_dates(t, 'c/')
      add_searchable_notes(t, 'c/')
    end

    def to_solr(solr_doc = {})
      super
      solr_doc['id'] = Arclight::NormalizedId.new(solr_doc['id']).to_s
      solr_doc['creator_sort'] = creator.to_a.join(', ') if creator.present?
      add_component_fields(solr_doc)
      solr_doc
    end

    private

    def add_component_fields(solr_doc)
      component_field_definitions.each do |field|
        # we want to use `set_field` rather than `insert_field` since we may be overriding fields
        Solrizer.set_field(solr_doc, field[:name], field[:value], field[:index_as])
      end
      add_date_ranges(solr_doc)
      add_normalized_title(solr_doc)
      resolve_repository(solr_doc)
      add_digital_content(prefix: 'c/did', solr_doc: solr_doc)
    end

    def component_field_definitions
      [
        { name: 'level', value: formatted_level, index_as: :facetable },
        { name: 'access_subjects', value: access_subjects, index_as: :facetable },
        { name: 'containers', value: containers, index_as: :symbol },
        { name: 'has_online_content', value: online_content?, index_as: :symbol }
      ]
    end

    def resolve_repository(solr_doc)
      repository = solr_doc[Solrizer.solr_name('repository', :displayable)]
      %i[displayable facetable].each do |index_as|
        Solrizer.set_field(solr_doc, 'repository', repository_as_configured(repository), index_as)
      end
    end

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

    def access_subjects
      subjects_array(%w[subject function occupation genreform], parent: 'c')
    end

    def containers
      contains = search('//container').to_a
      contains.map do |c|
        "#{c.attributes['type'].try(:value)} #{c.text}".strip
      end
    end
  end
end
