# frozen_string_literal: true

module Arclight
  # Render metadata for a search result.
  class SearchResultMetadataComponent < Blacklight::DocumentMetadataComponent
    def initialize(compact:, fields:, **args)
      @compact = compact
      super(fields: fields, **args)
    end

    def compact?
      @compact
    end
  end
end