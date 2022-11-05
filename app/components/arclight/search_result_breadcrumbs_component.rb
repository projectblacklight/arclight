# frozen_string_literal: true

module Arclight
  # Render the breadcrumbs for a search result document
  class SearchResultBreadcrumbsComponent < Blacklight::Component
    attr_reader :document

    def initialize(document:, count:)
      @document = document
      @count = count
      super
    end

    def breadcrumbs
      offset = grouped? ? 2 : 0

      Arclight::BreadcrumbComponent.new(document: document, count: @count, offset: offset)
    end

    def rendered_breadcrumbs
      @rendered_breadcrumbs ||= capture { render breadcrumbs }
    end

    def render?
      rendered_breadcrumbs.present?
    end

    delegate :grouped?, to: :helpers
  end
end
