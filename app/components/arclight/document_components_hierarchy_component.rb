# frozen_string_literal: true

module Arclight
  # Display a document's constituent components with appropriate lazy-loading
  # to keep the page load time reasonable.
  class DocumentComponentsHierarchyComponent < ViewComponent::Base
    # rubocop:disable Metrics/ParameterLists
    def initialize(document: nil, target_index: -1, minimum_pagination_size: 20, left_outer_window: 3, maximum_left_gap: 10, window: 10)
      super

      @document = document
      @target_index = target_index&.to_i || -1
      @minimum_pagination_size = minimum_pagination_size
      @left_outer_window = left_outer_window
      @maximum_left_gap = maximum_left_gap
      @window = window
    end
    # rubocop:enable Metrics/ParameterLists

    def paginate?
      @document.number_of_children > @minimum_pagination_size
    end

    def hierarchy_path(**kwargs)
      helpers.hierarchy_solr_document_path(id: @document.id, hierarchy: true, nest_path: params[:nest_path], **kwargs)
    end
  end
end
