# frozen_string_literal: true

module Arclight
  # Render a simple metadata field (e.g. without labels) in a .row div
  class MetadataSectionComponent < ViewComponent::Base
    with_collection_parameter :section

    def initialize(section:, presenter:, metadata_attr: {}, classes: %w[row dl-invert], heading: false)
      super

      @classes = classes
      @section = section
      @presenter = presenter.with_field_group(section)
      @heading = heading
      @metadata_attr = metadata_attr
    end

    def render?
      @presenter.fields_to_render.any?
    end
  end
end
