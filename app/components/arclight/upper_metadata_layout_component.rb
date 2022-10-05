# frozen_string_literal: true

module Arclight
  # Override upstream to remove bootstrap column classes
  class UpperMetadataLayoutComponent < Blacklight::MetadataFieldLayoutComponent
    def initialize(field:, label_class: nil, value_class: nil)
      super
    end
  end
end
