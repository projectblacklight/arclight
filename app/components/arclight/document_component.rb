# frozen_string_literal: true

module Arclight
  # Render a single document
  class DocumentComponent < Blacklight::DocumentComponent
    attr_reader :document

    def access_tab_items
      if document.collection?
        blacklight_config.show.context_access_tab_items || []
      else
        blacklight_config.show.component_access_tab_items || []
      end
    end

    def online_content?
      document.online_content? && (document.collection? || document.children?)
    end

    def blacklight_config
      presenter.configuration
    end
  end
end
