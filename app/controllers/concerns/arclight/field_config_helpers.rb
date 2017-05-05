# frozen_string_literal: true

module Arclight
  ##
  # A module to add configuration helpers for certain fields used by Arclight
  module FieldConfigHelpers
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        helper_method :repository_config_present
        helper_method :context_sidebar_repository
        helper_method :before_you_visit_note_present
        helper_method :context_sidebar_visit_note
      end
    end

    def repository_config_present(_, document)
      document.repository_config.present?
    end

    def context_sidebar_repository(args)
      document = args[:document]
      ApplicationController.renderer.render(
        'arclight/repositories/_in_person_repository',
        layout: false,
        locals: { repository: document.repository_config }
      )
    end

    def before_you_visit_note_present(_, document)
      document.repository_config && document.repository_config.visit_note.present?
    end

    def context_sidebar_visit_note(args)
      document = args[:document]
      document.repository_config.visit_note
    end
  end
end
