# frozen_string_literal: true

module Arclight
  # Render the masthead
  class MastheadComponent < Blacklight::Component
    def heading
      t('arclight.masthead_heading_html')
    end
  end
end
