# frozen_string_literal: true

module Arclight
  class SidebarComponent < Blacklight::Document::SidebarComponent
    delegate :blacklight_config, :document_presenter, :should_render_field?,
             :turbo_frame_tag, to: :helpers
  end
end
