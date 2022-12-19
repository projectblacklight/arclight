# frozen_string_literal: true

module Arclight
  # Render an online status indicator for a document
  class OnlineStatusIndicatorComponent < Blacklight::Component
    def initialize(document:, **)
      @document = document
      super
    end

    def render?
      @document.online_content?
    end

    def call
      tag.span helpers.blacklight_icon(:online), class: 'al-online-content-icon'
    end
  end
end
