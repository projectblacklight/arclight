# frozen_string_literal: true

module Arclight
  # Custom presentation methods for show partial
  class ShowPresenter < Blacklight::ShowPresenter
    def heading
      document.normalized_title
    end

    def with_field_group(group)
      self.field_group = group
      self
    end

    def fields_have_content?(field_accessor)
      generic_document_fields(field_accessor).any? do |_, field|
        generic_should_render_field?(field_accessor, field)
      end
    end

    ##
    # Calls the method for a configured field
    def generic_should_render_field?(config_field, field)
      view_context.public_send(:"should_render_#{config_field}?", document, field)
    end

    ##
    # Calls the method for a configured field
    def generic_document_fields(config_field)
      view_context.public_send(:"document_#{config_field}s")
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
