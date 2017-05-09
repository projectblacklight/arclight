# frozen_string_literal: true

module Arclight
  # Custom presentation methods for index partials
  class IndexPresenter < Blacklight::IndexPresenter
    def label(*)
      view_context.safe_join([normalize_title(super), document.unitdate].compact.map(&:html_safe), ', ')
    end

    private

    # TODO: duplicate of ShowPresenter#normalize_title
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
