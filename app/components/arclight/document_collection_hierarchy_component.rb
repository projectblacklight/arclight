# frozen_string_literal: true

module Arclight
  # Display a single document in the collection hierarchy
  class DocumentCollectionHierarchyComponent < Arclight::SearchResultComponent
    # @param [Blacklight::DocumentPresenter] document
    # @param [String] nest_path determines which element to highlight
    def initialize(document: nil, nest_path: nil, blacklight_config: nil, **kwargs)
      super(document: document, **kwargs)
      @nest_path = nest_path
      @blacklight_config = blacklight_config
    end

    attr_reader :blacklight_config

    def classes
      super - ['row']
    end

    # we want to eager-load this document's children if we're in the
    # target document's component hierarchy
    def show_expanded?
      within_original_tree?
    end

    # Solr nest paths are constructed using the path name and an index, e.g.
    # `/components#5/components#3`.
    #
    # @return [String] the targeted index for this level of the hierarchy
    def target_index
      return -1 unless within_original_tree?

      remaining_path = nest_path.sub("#{@document.nest_path}/", '')
      current_component, _rest = remaining_path.split('/', 2)
      _name, index = current_component.split('#', 2)

      index&.to_i
    end

    private

    # We're in the targeted document's original tree if the target nest path
    # includes this document's path.
    def within_original_tree?
      nest_path&.start_with? "#{@document.nest_path}/"
    end

    def current_target?
      nest_path == @document.nest_path
    end

    def online_status
      render online_status_component.new(document: @document)
    end

    def online_status_component
      blacklight_config.show.online_status_component || Arclight::OnlineStatusIndicatorComponent
    end

    attr_reader :nest_path
  end
end
