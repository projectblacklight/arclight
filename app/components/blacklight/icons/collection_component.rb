# frozen_string_literal: true

module Blacklight
  module Icons
    # The collection icon
    class CollectionComponent < Blacklight::Icons::IconComponent
      # Used unmodified from https://fontawesome.com
      # CC BY 4.0 https://creativecommons.org/licenses/by/4.0/
      self.svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 512 512"><path d="M32 448c0 17.7 14.3 32 32 32h384c17.7 0 32-14.3 32-32V160H32v288zm160-212c0-6.6 5.4-12 12-12h104c6.6 0 12 5.4 12 12v8c0 6.6-5.4 12-12 12H204c-6.6 0-12-5.4-12-12v-8zM480 32H32C14.3 32 0 46.3 0 64v48c0 8.8 7.2 16 16 16h480c8.8 0 16-7.2 16-16V64c0-17.7-14.3-32-32-32z"/></svg>
      SVG
    end
  end
end
