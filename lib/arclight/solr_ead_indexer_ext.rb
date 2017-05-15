# frozen_string_literal: true

module Arclight
  ##
  # An module to extend SolrEad::Indexer behaviors to allow us to add
  # additional behaviors that require knowledge of the entire XML document.
  module SolrEadIndexerExt
    def additional_component_fields(node, addl_fields = {})
      solr_doc = super

      add_collection_context_to_parent_fields(node, solr_doc)

      add_count_of_child_compontents(node, solr_doc)

      solr_doc
    end

    def delete_all
      solr.delete_by_query('*:*')
      solr.commit
    end

    private

    ##
    # SolrEad does not index the collection id/title into the parent
    # fields, so we're adding that context to the beginning of those fields
    def add_collection_context_to_parent_fields(node, solr_doc)
      add_collection_id(node, solr_doc)
      add_collection_title(node, solr_doc)
    end

    def add_collection_id(node, solr_doc)
      eadid = Arclight::NormalizedId.new(node.xpath('//eadid').text).to_s
      parent_id_field_name = Solrizer.solr_name('parent', :stored_sortable)
      parent_ids_field_name = Solrizer.solr_name('parent', :displayable)

      solr_doc[parent_id_field_name] = eadid if solr_doc[parent_id_field_name].blank?
      solr_doc[parent_ids_field_name] = (solr_doc[parent_ids_field_name] || []).unshift(eadid)
    end

    def add_collection_title(node, solr_doc)
      eadtitle = node.xpath('//archdesc/did/unittitle').text
      parent_titles_field_name = Solrizer.solr_name('parent_unittitles', :displayable)
      parent_titles_search_field_name = Solrizer.solr_name('parent_unittitles', :searchable)

      solr_doc[parent_titles_field_name] = (solr_doc[parent_titles_field_name] || []).unshift(eadtitle)
      solr_doc[parent_titles_search_field_name] = (solr_doc[parent_titles_search_field_name] || []).unshift(eadtitle)
    end

    def add_count_of_child_compontents(node, solr_doc)
      solr_doc[Solrizer.solr_name('child_component_count', type: :integer)] = node.xpath('count(c)').to_i
    end
  end
end
