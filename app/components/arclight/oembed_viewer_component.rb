# frozen_string_literal: true

module Arclight
  # Render an oembed viewer for a document
  class OembedViewerComponent < ViewComponent::Base
    with_collection_parameter :resource

    def initialize(resource:, document:, depth: 0)
      super

      @resource = resource
      @document = document
      @depth = depth
    end
  end
end
