# frozen_string_literal: true

module Arclight
  ##
  # A module to add configuration helpers for certain fields used by Arclight
  module FieldConfigHelpers
    include Arclight::EadFormatHelpers

    def repository_config_present(_, document)
      document.repository_config.present?
    end

    def item_requestable?(_, options)
      document = options[:document]
      request_config_present('', document)
    end

    def request_config_present(var, document)
      repository_config_present(var, document) &&
        document.repository_config.request_config_present?
    end

    def context_access_tab_repository(args)
      document = args[:document]
      ApplicationController.renderer.render(
        'arclight/repositories/_in_person_repository',
        layout: false,
        locals: { repository: document.repository_config }
      )
    end

    def access_repository_contact(args)
      document = args[:document]
      ApplicationController.renderer.render(
        'arclight/repositories/_repository_contact',
        layout: false,
        locals: { repository: document.repository_config }
      )
    end

    def before_you_visit_note_present(_, document)
      document.repository_config && document.repository_config.visit_note.present?
    end

    def context_access_tab_visit_note(args)
      document = args[:document]
      document.repository_config.visit_note
    end

    def link_to_name_facet(args)
      options = args[:config]&.separator_options || {}
      values = args[:value] || []

      values.map do |value|
        link_to(
          value,
          search_action_path(f: { names_ssim: [value] })
        )
      end.to_sentence(options).html_safe
    end
  end
end
