# frozen_string_literal: true

module Arclight
  # Render various actions for a collection (e.g. requesting, download links, etc)
  class CollectionContextComponent < ViewComponent::Base
    def initialize(presenter:)
      super

      @collection = presenter.document.collection
    end

    attr_reader :collection

    def title
      collection.normalized_title
    end
  end
end
