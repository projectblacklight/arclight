# frozen_string_literal: true

module Arclight
  # Component for rendering an expand button inside the hierarchy view
  class ExpandHierarchyButtonComponent < Blacklight::Component
    def initialize(path:, classes: 'btn btn-secondary btn-sm')
      super
      @path = path
      @classes = classes
    end

    def expand_link
      link_to t('arclight.views.show.expand'), @path, class: @classes
    end
  end
end
