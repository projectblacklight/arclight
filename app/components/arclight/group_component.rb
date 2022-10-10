# frozen_string_literal: true

module Arclight
  # Render a collection document for a
  # grouped search result view
  class GroupComponent < Blacklight::Document::GroupComponent
    def compact?
      helpers.document_index_view_type.to_s == 'compact'
    end

    def document
      @document ||= @group.docs.first.parent_document
    end

    def presenter
      @presenter ||= Arclight::ShowPresenter.new(document, helpers).with_field_group('group_header_field')
    end
  end
end
