# frozen_string_literal: true

module Arclight
  # Override Blacklight's SearchBarComponent to add a dropdown for choosing
  # the context of the search (within this collection or all collections)
  class SearchBarComponent < Blacklight::SearchBarComponent
    def initialize(params:, **kwargs)
      super

      @kwargs = kwargs
    end
  end
end
