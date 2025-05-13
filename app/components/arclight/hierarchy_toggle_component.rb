# frozen_string_literal: true

module Arclight
  # Component for rendering the plus/minus icons at each level of expandable hierarchy components
  class HierarchyToggleComponent < ViewComponent::Base
    attr_reader :document, :expanded

    def initialize(document:, expanded:)
      @document = document
      @expanded = expanded
      super
    end

    delegate :blacklight_icon, to: :helpers

    def render?
      @document.children?
    end
  end
end
