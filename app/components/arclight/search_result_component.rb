# frozen_string_literal: true

module Arclight
  # Render a document for a search result; this works with
  # both the compact and list views for grouped or ungrouped
  # results.
  class SearchResultComponent < Blacklight::DocumentComponent
    attr_reader :document

    # We need to initialize the view component counter variable
    # See https://viewcomponent.org/guide/collections.html#collection-counter
    def initialize(search_result_counter: nil, **kwargs)
      super
    end

    def compact?
      presenter.view_config.key.to_s == 'compact'
    end

    def icon
      helpers.blacklight_icon helpers.document_or_parent_icon(@document)
    end
  end
end
