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
      t.unitdate_inclusive(path: 'c/did/unitdate[@type=\'inclusive\']', index_as: %i[displayable])
      t.unitdate_bulk(path: 'c/did/unitdate[@type=\'bulk\']', index_as: %i[displayable])
      t.unitdate_other(path: 'c/did/unitdate[not(@type)]', index_as: %i[displayable])
      t.accessrestrict(path: 'c/accessrestrict/p', index_as: %i[displayable])
      t.scopecontent(path: 'c/scopecontent/p', index_as: %i[displayable])
      t.normal_unit_dates(path: 'c/did/unitdate/@normal')
    end

    def to_solr(solr_doc = {})
      super
      solr_doc['id'] = Arclight::NormalizedId.new(solr_doc['id']).to_s
      Solrizer.insert_field(solr_doc, 'level', formatted_level, :facetable) # human-readable for facet `level_sim`
      Solrizer.insert_field(solr_doc, 'access_subjects', access_subjects, :facetable)
      Solrizer.insert_field(solr_doc, 'containers', containers, :symbol)
      add_date_ranges(solr_doc)
      add_normalized_title(solr_doc)
      resolve_repository(solr_doc)
      add_digital_content(prefix: 'c/did', solr_doc: solr_doc)

      solr_doc
    end

    private

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
