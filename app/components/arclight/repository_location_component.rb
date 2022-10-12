# frozen_string_literal: true

module Arclight
  # Render the repository location card as a metadata field
  class RepositoryLocationComponent < Blacklight::MetadataFieldComponent
    def repository
      @field.values.first
    end
  end
end
