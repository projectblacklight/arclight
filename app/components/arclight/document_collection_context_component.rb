# frozen_string_literal: true

module Arclight
  # Display a single document in the collection
  class DocumentCollectionContextComponent < Arclight::SearchResultComponent
    # @param [SolrDocument] document
    def initialize(document: nil, blacklight_config: nil, **kwargs)
      super(document: document, **kwargs)
      @blacklight_config = blacklight_config
    end

    attr_reader :blacklight_config

    def classes
      (super - ['row'] + ['al-collection-context']).flatten
    end

    private

    def online_status
      render online_status_component.new(document: @document)
    end

    def online_status_component
      blacklight_config.show.online_status_component || Arclight::OnlineStatusIndicatorComponent
    end
  end
end
