# frozen_string_literal: true

module Arclight
  # Override Blacklight's SearchBarComponent to add a dropdown for choosing
  # the context of the search (within this collection or all collections)
  class SearchBarComponent < Blacklight::SearchBarComponent
    def initialize(**kwargs)
      super

      @kwargs = kwargs
    end

    def within_collection_options
      options_for_select(
        [
          [t('arclight.within_collection_dropdown.all_collections'), ''],
          [t('arclight.within_collection_dropdown.this_collection'), collection_name]
        ],
        selected: collection_name.presence || '',
        disabled: (collection_name if collection_name.blank?)
      )
    end

    def collection_name
      Array(@params.dig(:f, :collection_sim)).first ||
        (helpers.current_context_document.respond_to?(:collection_name) && helpers.current_context_document&.collection_name)
    end
  end
end
