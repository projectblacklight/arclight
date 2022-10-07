# frozen_string_literal: true

module Arclight
  # Render a simple metadata field (e.g. without labels) in a .row div
  class IndexMetadataFieldComponent < Blacklight::MetadataFieldComponent
    def initialize(field:, classes: ['col'], **kwargs)
      super(field: field, **kwargs)

      @classes = classes + ["al-document-#{@field.key.dasherize}"]
    end
  end
end
