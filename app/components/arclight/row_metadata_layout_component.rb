# frozen_string_literal: true

module Arclight
  # Override upstream to use bootstrap rows rather than dl/dt/dd
  class RowMetadataLayoutComponent < Blacklight::MetadataFieldLayoutComponent
    def truncate?
      !!@field.field_config.truncate
    end
  end
end
