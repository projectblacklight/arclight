# frozen_string_literal: true

module Arclight
  # Render a single document
  class DocumentComponent < Blacklight::DocumentComponent
    attr_reader :document

    def online_content?
      document.online_content? && (document.collection? || document.children?)
    end

    def blacklight_config
      presenter.configuration
    end

    def breadcrumb_component
      blacklight_config.show.breadcrumb_component || Arclight::BreadcrumbsHierarchyComponent
    end

    def metadata_partials
      blacklight_config.show.metadata_partials || []
    end

    def component_metadata_partials
      blacklight_config.show.component_metadata_partials || []
    end

    def access
      render (blacklight_config.show.access_component || Arclight::AccessComponent).new(presenter: presenter)
    end
  end
end
