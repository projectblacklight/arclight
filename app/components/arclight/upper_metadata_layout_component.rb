# frozen_string_literal: true

module Arclight
  # Override upstream to add an offset bootstrap column class
  class UpperMetadataLayoutComponent < Blacklight::MetadataFieldLayoutComponent
    def initialize(field:, index: 0, label_class: 'col-md-3 offset-md-1', value_class: 'col-md-8')
      @index = index
      super(field: field, label_class: label_class, value_class: value_class)
    end
  end
end
