# frozen_string_literal: true

module Arclight
  # Custom presentation methods for show partial
  class ShowPresenter < Blacklight::ShowPresenter
    def heading
      view_context.safe_join([normalize_title(super), document.unitdate].compact.map(&:html_safe), ', ')
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

    # TODO: duplicate of IndexPresenter#normalize_title
    def normalize_title(title)
      if document.unitdate.blank?
        return document.id.to_s if title.blank? # fallback to id when nothing there
      elsif title.blank? || title == document.id.to_s # unitdate is present
        return nil
      end
      title.gsub(/\s*,\s*$/, '') # strip trailing commas
    end
  end
end
