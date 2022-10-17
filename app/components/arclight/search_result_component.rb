# frozen_string_literal: true

module Arclight
  # Render a document for a search result; this works with
  # both the compact and list views for grouped or ungrouped
  # results.
  class SearchResultComponent < Blacklight::DocumentComponent
    attr_reader :document

    def compact?
      presenter.view_config.key.to_s == 'compact'
    end

    def icon
      blacklight_icon helpers.document_or_parent_icon(@document)
    end

    def breadcrumbs
      args = {
        offset: grouped? ? 2 : 0,
        count: compact? ? 2 : nil
      }

      Arclight::BreadcrumbComponent.new(document: @document, **args)
    end

    delegate :grouped?, to: :helpers
  end
end
