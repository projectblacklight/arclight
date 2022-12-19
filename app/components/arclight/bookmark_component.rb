# frozen_string_literal: true

module Arclight
  class BookmarkComponent < Blacklight::Document::BookmarkComponent
    delegate :current_or_guest_user, to: :helpers
    attr_accessor :document
  end
end
