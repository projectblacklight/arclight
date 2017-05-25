# frozen_string_literal: true

module Arclight
  ##
  # Customized Search Behavior for Arclight
  module SearchBehavior
    extend ActiveSupport::Concern

    included do
      self.default_processor_chain += %i[add_hierarchy_max_rows add_highlighting]
    end

    ##
    # For the hierarchy view, set a higher (unlimited) maximum document return
    def add_hierarchy_max_rows(solr_params)
      if blacklight_params[:view] == 'hierarchy'
        solr_params[:rows] = 999_999_999
      end
      solr_params
    end

    def add_highlighting(solr_params)
      if blacklight_params[:view] == 'hierarchy'
        solr_params['hl'] = false
      else
        solr_params['hl'] = true
        solr_params['hl.fl'] = 'text'
        solr_params['hl.snippets'] = 3
      end
      solr_params
    end
  end
end
