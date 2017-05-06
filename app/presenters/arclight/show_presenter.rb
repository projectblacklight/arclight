# frozen_string_literal: true

module Arclight
  # Custom presentation methods for show partial
  class ShowPresenter < Blacklight::ShowPresenter
    def heading
      title = super
      delimiter = heading_delimiter(title)
      view_context.safe_join([title, document.unitdate].compact, delimiter)
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

    def heading_delimiter(title)
      return ', ' unless title.ends_with?(',')
      ' '
    end
  end
end
