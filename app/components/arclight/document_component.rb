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
  end
end
