# frozen_string_literal: true

module Arclight
  # Custom presentation methods for index partials
  class IndexPresenter < Blacklight::IndexPresenter
    def label(*)
      document.normalized_title
    end
  end
end
