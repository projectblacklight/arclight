# frozen_string_literal: true

module Arclight
  # Render a simple metadata field (e.g. without labels) in a .row div
  class MetadataSectionComponent < ViewComponent::Base
    with_collection_parameter :section

    # Section headings are looked up dynamically via t("arclight.views.show.sections.#{section}")
    # i18n-tasks-use t('arclight.views.show.sections.background_field')
    # i18n-tasks-use t('arclight.views.show.sections.collection_context_field')
    # i18n-tasks-use t('arclight.views.show.sections.component_field')
    # i18n-tasks-use t('arclight.views.show.sections.component_indexed_terms_field')
    # i18n-tasks-use t('arclight.views.show.sections.indexed_terms_field')
    # i18n-tasks-use t('arclight.views.show.sections.related_field')
    # i18n-tasks-use t('arclight.views.show.sections.scope_and_arrangement_field')
    # i18n-tasks-use t('arclight.views.show.sections.summary_field')

    def initialize(section:, presenter:, metadata_attr: {}, classes: %w[row dl-invert], heading: false)
      super()

      @classes = classes
      @section = section
      @presenter = presenter.with_field_group(section)
      @heading = heading
      @metadata_attr = metadata_attr
    end

    def render?
      @presenter.fields_to_render.any?
    end
  end
end
