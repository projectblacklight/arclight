# frozen_string_literal: true

module Arclight
  # Custom presentation methods for show partial
  class ShowPresenter < Blacklight::ShowPresenter
    def heading
      title = super
      date = document.fetch('unitdate_ssm', [])
      title += ", #{date.first}" if date.present?
      title
    end

    def with_field_group(group)
      self.field_group = group
      self
    end

    private

    def field_group
      @field_group || 'show_field'
    end

    attr_writer :field_group

    def field_config(field)
      BlacklightFieldConfigurationFactory.for(config: configuration, field: field, field_group: field_group)
    end
  end
end
