# frozen_string_literal: true

module Arclight
  # Render the box that displays a link to filter only for online content
  class OnlineContentFilterComponent < Blacklight::Component
    def initialize(document:)
      @document = document
      super()
    end

    def render?
      @document.collection? && @document.online_content?
    end

    delegate :collection_name, to: :@document
  end
end
