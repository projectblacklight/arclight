# frozen_string_literal: true

module Arclight
  # Override upstream to add an offset bootstrap column class
  class UpperMetadataLayoutComponent < Blacklight::MetadataFieldLayoutComponent
    def initialize(field:, label_class: 'col-md-3 offset-md-1', value_class: 'col-md-8')
      super
    end
  end
end
