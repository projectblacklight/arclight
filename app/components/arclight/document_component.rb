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

    def metadata_partials
      blacklight_config.show.metadata_partials || []
    end

    def component_metadata_partials
      blacklight_config.show.component_metadata_partials || []
    end

    def context_access_tab_items
      blacklight_config.show.context_access_tab_items || []
    end

    def component_access_tab_items
      blacklight_config.show.component_access_tab_items || []
    end
  end
end
