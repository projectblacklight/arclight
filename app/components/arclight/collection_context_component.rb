# frozen_string_literal: true

module Arclight
  # Render various actions for a collection (e.g. requesting, download links, etc)
  class CollectionContextComponent < ViewComponent::Base
    def initialize(presenter:, download_component:)
      super

      @collection = presenter.document.collection
      @download_component = download_component
    end

    attr_reader :collection

    def title
      collection.normalized_title
    end

    def document_download
      render @download_component.new(downloads: collection.downloads) || Arclight::DocumentDownloadComponent.new(downloads: collection.downloads)
    end

    def collection_info
      render Arclight::CollectionInfoComponent.new(collection: collection)
    end
  end
end
