# frozen_string_literal: true

module Arclight
  # Render the breadcrumbs for a search result document
  class SearchResultBreadcrumbsComponent < Blacklight::MetadataFieldComponent
    delegate :document, to: :@field

    def initialize(field:, **kwargs)
      @field = field
      super
    end

    def breadcrumbs
      offset = grouped? ? 2 : 0

      Arclight::BreadcrumbComponent.new(document: document, count: breadcrumb_count, offset: offset)
    end

    def rendered_breadcrumbs
      @rendered_breadcrumbs ||= capture { render breadcrumbs }
    end

    def render?
      rendered_breadcrumbs.present?
    end

    def breadcrumb_count
      @field.field_config.compact&.dig(:count) if compact?
    end

    delegate :grouped?, to: :helpers

    def compact?
      helpers.document_index_view_type == :compact
    end
  end
end
