# frozen_string_literal: true

module Arclight
  # Render "related" information for a document
  class RelatedComponent < ViewComponent::Base
    def initialize(presenter:)
      super
      @show_config = presenter.configuration.show
      @presenter = presenter
    end

    attr_reader :presenter, :show_config

    delegate :collection?, to: :presenter

    # @return Array<Symbol> a list of metadata section names
    def section_names
      return Array(collection_related_items) if collection?

      Array(component_related_items)
    end

    delegate :collection_related_items, :component_related_items, to: :show_config
  end
end
