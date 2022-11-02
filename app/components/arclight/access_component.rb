# frozen_string_literal: true

module Arclight
  # Render access information for a document
  class AccessComponent < ViewComponent::Base
    def initialize(presenter:)
      super
      @show_config = presenter.configuration.show
      @presenter = presenter
    end

    attr_reader :presenter, :show_config

    delegate :collection?, to: :presenter

    # @return Array<Symbol> a list of metadata section names
    def section_names
      return Array(show_config.context_access_tab_items) if collection?

      Array(show_config.component_access_tab_items)
    end
  end
end
