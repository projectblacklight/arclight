# frozen_string_literal: true

module Arclight
  # ViewComponent for rendering a single document download link
  class DocumentDownloadComponent < ViewComponent::Base
    def initialize(downloads:, **kwargs)
      super

      @downloads = downloads
      @link_options = kwargs
    end

    attr_reader :downloads

    delegate :files, to: :downloads

    def render?
      files.present?
    end

    # i18n-tasks-use t('arclight.views.show.download.multiple.pdf')
    # i18n-tasks-use t('arclight.views.show.download.multiple.ead')
    def dropdown_label(file)
      t(file.type, scope: 'arclight.views.show.download.multiple')
    end

    # i18n-tasks-use t('arclight.views.show.download.single.pdf')
    # i18n-tasks-use t('arclight.views.show.download.single.ead')
    def label(file)
      t(file.type, scope: 'arclight.views.show.download.single')
    end

    # From https://icons.getbootstrap.com/icons/download/
    def download_icon
      icon = <<~HTML
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-download" viewBox="0 0 16 16">
          <path d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z"/>
          <path d="M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z"/>
        </svg>
      HTML
      icon.html_safe # rubocop:disable Rails/OutputSafety
    end

    # This is an extension point where one could configure a different icon per file type
    def icon_for(_type)
      download_icon
    end
  end
end
