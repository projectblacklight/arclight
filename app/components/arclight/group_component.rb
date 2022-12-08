# frozen_string_literal: true

module Arclight
  # Render a collection document for a
  # grouped search result view
  class GroupComponent < Blacklight::Document::GroupComponent
    def compact?
      helpers.document_index_view_type.to_s == 'compact'
    end

    def document
      @document ||= @group.docs.first.collection
    end

    def presenter
      @presenter ||= Arclight::ShowPresenter.new(document, helpers).with_field_group('group_header_field')
    end

    def search_within_collection_url
      search_catalog_path(helpers.search_without_group.merge(f: { collection: [document.collection_name] }))
    end
  end
end
