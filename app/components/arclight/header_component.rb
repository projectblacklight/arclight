# frozen_string_literal: true

module Arclight
  # Provides a header with a masthead
  class HeaderComponent < Blacklight::HeaderComponent
    def masthead
      render Arclight::MastheadComponent.new
    end
  end
end
