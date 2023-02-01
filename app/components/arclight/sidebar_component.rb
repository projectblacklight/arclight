# frozen_string_literal: true

module Arclight
  # A sidebar with collection context widget and tools
  class SidebarComponent < Blacklight::Document::SidebarComponent
    delegate :blacklight_config, :document_presenter, :should_render_field?,
             :turbo_frame_tag, to: :helpers

    def collection_context
      render Arclight::CollectionContextComponent.new(presenter: document_presenter(document), download_component: Arclight::DocumentDownloadComponent)
    end

    def collection_sidebar
      render Arclight::CollectionSidebarComponent.new(document: document,
                                                      collection_presenter: document_presenter(document.collection),
                                                      partials: blacklight_config.show.metadata_partials)
    end
  end
end
