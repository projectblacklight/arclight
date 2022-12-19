# frozen_string_literal: true

module Arclight
  # Render the hierarchy for a document
  class BreadcrumbsHierarchyComponent < ViewComponent::Base
    delegate :document, to: :@presenter
    delegate :blacklight_icon, to: :helpers

    def initialize(presenter:)
      super

      @presenter = presenter
      collections, @parents_under_collection = document.parents.partition(&:collection?)
      @collection = collections.first
    end

    attr_reader :collection, :parents_under_collection

    def repository
      return tag.span(t('arclight.show_breadcrumb_label')) if document.repository_config.blank?

      link_to(document.repository_config.name, helpers.arclight_engine.repository_path(document.repository_config.slug))
    end
  end
end
