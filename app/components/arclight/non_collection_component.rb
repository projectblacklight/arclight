# frozen_string_literal: true

module Arclight
  # Render a single non-collection document
  class NonCollectionComponent < Blacklight::DocumentComponent
    attr_reader :document

    def blacklight_config
      presenter.configuration
    end

    def online_content?
      document.online_content? && document.children?
    end
  end
end
