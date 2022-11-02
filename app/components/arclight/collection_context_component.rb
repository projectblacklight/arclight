# frozen_string_literal: true

module Arclight
  # Render various actions for a collection (e.g. requesting, download links, etc)
  class CollectionContextComponent < ViewComponent::Base
    def initialize(presenter:)
      super

      @presenter = presenter
    end

    delegate :document, to: :@presenter
    delegate :collection, to: :document

    def title
      collection.normalized_title
    end
  end
end
