# frozen_string_literal: true

module Blacklight
  module Icons
    # The compact icon
    class CompactComponent < Blacklight::Icons::IconComponent
      self.svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" height="24" width="24" viewBox="0 0 24 24"><path d="M3,15H21V13H3Zm0,4H21V17H3Zm0-8H21V9H3ZM3,5V7H21V5Z"/></svg>
      SVG
    end
  end
end
