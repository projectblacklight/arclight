# frozen_string_literal: true

module Blacklight
  module Icons
    # The minus icon
    class MinusComponent < Blacklight::Icons::IconComponent
      self.svg = <<~SVG
        <svg xmlns='http://www.w3.org/2000/svg' fill="currentColor" viewBox='0 0 475 512'><path stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' stroke='rgb(0, 0, 0)' d='M64 32C28.7 32 0 60.7 0 96V416c0 35.3 28.7 64 64 64H384c35.3 0 64-28.7 64-64V96c0-35.3-28.7-64-64-64H64zm88 200H296c13.3 0 24 10.7 24 24s-10.7 24-24 24H152c-13.3 0-24-10.7-24-24s10.7-24 24-24z'/></svg>
      SVG
    end
  end
end
