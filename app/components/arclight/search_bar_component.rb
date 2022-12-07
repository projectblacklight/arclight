# frozen_string_literal: true

module Arclight
  # Override Blacklight's SearchBarComponent to add a dropdown for choosing
  # the context of the search (within "this collection" or "all collections").
  # If a collection has not been chosen, it displays a dropdown with only "all collections"
  # as the only selectable option.
  class SearchBarComponent < Blacklight::SearchBarComponent
    def initialize(**kwargs)
      super

      @kwargs = kwargs
    end

    def within_collection_options
      value = collection_name || 'none-selected'
      options_for_select(
        [
          [t('arclight.within_collection_dropdown.all_collections'), ''],
          [t('arclight.within_collection_dropdown.this_collection'), value]
        ],
        selected: collection_name,
        disabled: 'none-selected'
      )
    end

    def collection_name
      @collection_name ||= Array(@params.dig(:f, :collection)).first ||
                           helpers.current_context_document&.collection_name
    end
  end
end
