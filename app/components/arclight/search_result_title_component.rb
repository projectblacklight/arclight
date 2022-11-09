# frozen_string_literal: true

module Arclight
  # Render a document title for a search result
  class SearchResultTitleComponent < Blacklight::DocumentTitleComponent
    def initialize(compact:, **args)
      @compact = compact
      super(**args)
    end

    def compact?
      @compact
    end
  end
end
