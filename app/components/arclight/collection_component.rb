# frozen_string_literal: true

module Arclight
  # Render a single collection document
  class CollectionComponent < Blacklight::DocumentComponent
    def blacklight_config
      presenter.configuration
    end
    attr_reader :document

    delegate :online_content?, to: :document
  end
end
