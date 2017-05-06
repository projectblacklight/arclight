# frozen_string_literal: true

module Arclight
  # Custom presentation methods for index partials
  class IndexPresenter < Blacklight::IndexPresenter
    def label(*)
      title = super
      delimiter = heading_delimiter(title)
      view_context.safe_join([title, document.unitdate].compact, delimiter)
    end

    private

    def heading_delimiter(title)
      return ', ' unless title.ends_with?(',')
      ' '
    end
  end
end
