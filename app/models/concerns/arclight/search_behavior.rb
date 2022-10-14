# frozen_string_literal: true

module Arclight
  ##
  # Customized Search Behavior for Arclight
  module SearchBehavior
    extend ActiveSupport::Concern

    included do
      self.default_processor_chain += %i[
        add_hierarchy_max_rows
        add_hierarchy_sort
        add_highlighting
        add_grouping
      ]
    end

    ##
    # Override Blacklight's method so that some views don't add Solr facets into the request.
    def add_facetting_to_solr(solr_params)
      return solr_params if %w[collection_context].include? blacklight_params[:view]

      super(solr_params)
    end

    ##
    # For the collection_context views, set a higher (unlimited) maximum document return
    def add_hierarchy_max_rows(solr_params)
      solr_params[:rows] = 999_999_999 if %w[collection_context].include? blacklight_params[:view]
      solr_params
    end

    ##
    # For the asynch views, set the sort order to preserve the order of components
    def add_hierarchy_sort(solr_params)
      solr_params[:sort] = 'sort_ii asc' if %w[collection_context].include? blacklight_params[:view]
      solr_params
    end

    ##
    # Add highlighting
    def add_highlighting(solr_params)
      solr_params['hl'] = true
      solr_params['hl.fl'] = 'text'
      solr_params['hl.snippets'] = 3
      solr_params
    end

    ##
    # Adds grouping parameters for Solr if enabled
    def add_grouping(solr_params)
      solr_params.merge!(Arclight::Engine.config.catalog_controller_group_query_params) if blacklight_params[:group] == 'true'

      solr_params
    end
  end
end
