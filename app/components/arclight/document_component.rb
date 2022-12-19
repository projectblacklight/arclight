# frozen_string_literal: true

module Arclight
  # Render a single document
  class DocumentComponent < Blacklight::DocumentComponent
    attr_reader :document

    def online_content?
      document.online_content? && (document.collection? || document.children?)
    end

    def blacklight_config
      presenter.configuration
    end

    # @return [Blacklight::Configuration::ToolConfig] the configuration for the bookmark
    def bookmark_config
      blacklight_config.index.document_actions.arclight_bookmark_control
    end

    def breadcrumb_component
      blacklight_config.show.breadcrumb_component || Arclight::BreadcrumbsHierarchyComponent
    end

    def metadata_partials
      blacklight_config.show.metadata_partials || []
    end

    def component_metadata_partials
      blacklight_config.show.component_metadata_partials || []
    end

    def online_filter
      render Arclight::OnlineContentFilterComponent.new(document: document)
    end

    def access
      render (blacklight_config.show.access_component || Arclight::AccessComponent).new(presenter: presenter)
    end

    def toggle_sidebar
      button_tag(t('arclight.views.show.toggle_sidebar'),
                 type: :button,
                 class: 'btn btn-sm btn-secondary d-lg-none sidebar-toggle',
                 data: { bs_toggle: 'offcanvas', bs_target: '#sidebar' },
                 aria: { controls: 'sidebar' })
    end
  end
end
