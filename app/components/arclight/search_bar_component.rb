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
      all_collections_option = [t('arclight.within_collection_dropdown.all_collections'), '']
      this_collection_option = [t('arclight.within_collection_dropdown.this_collection'), collection_name || 'none-selected']
      this_repository_option = [t('arclight.within_collection_dropdown.this_repository'), repository_name].compact

      options = [all_collections_option]
      options << this_collection_option if collection_name.present?
      options << this_repository_option if repository_name.present?

      options_for_select(
        options,
        selected: selected_option(options),
        disabled: 'none-selected'
      )
    end

    def collection_name
      @collection_name ||= Array(@params.dig(:f, :collection)).reject(&:empty?).first ||
                           helpers.current_context_document&.collection_name
    end

    def repository_name
      if controller.controller_name == "repositories" && controller.action_name == "show"
          @repository_name ||= Repository.find_by!(slug: params[:id]).name
      else
        @repository_name ||= Array(@params.dig(:f, :repository)).reject(&:empty?).first      
      end
    end

    def selected_option(options)
      options.detect { |option| option.last.present? }&.last || ''
    end
  end
end
