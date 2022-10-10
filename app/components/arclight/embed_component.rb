# frozen_string_literal: true

module Arclight
  # Render digital object links for a document
  class EmbedComponent < ViewComponent::Base
    def initialize(document:, presenter:, **kwargs)
      super

      @document = document
      @presenter = presenter
    end

    def render?
      resources.any?
    end

    def embeddable_resources
      resources.first(1).select { |object| embeddable?(object) }
    end

    def linked_resources
      resources - embeddable_resources
    end

    def resources
      @resources ||= @document.digital_objects || []
    end

    def depth
      @document.parents.length || 0
    end

    def embeddable?(object)
      exclude_patterns.none? do |pattern|
        object.href =~ pattern
      end
    end

    def exclude_patterns
      Arclight::Engine.config.oembed_resource_exclude_patterns
    end
  end
end
