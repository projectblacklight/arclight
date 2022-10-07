# frozen_string_literal: true

module Arclight
  # ViewComponent for rendering a single document download link
  class DocumentDownloadComponent < ViewComponent::Base
    with_collection_parameter :file

    def initialize(file:, **kwargs)
      super

      @file = file
      @link_options = kwargs
    end

    def label
      if @file.size
        t("arclight.views.show.download_with_size.#{@file.type}", size: @file.size)
      else
        t("arclight.views.show.download.#{@file.type}")
      end
    end

    def icon
      blacklight_icon(@file.type, classes: 'al-show-actions-box-downloads-file')
    end
  end
end
