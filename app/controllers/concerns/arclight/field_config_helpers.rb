# frozen_string_literal: true

module Arclight
  ##
  # A module to add configuration helpers for certain fields used by Arclight
  module FieldConfigHelpers
    extend ActiveSupport::Concern
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::TagHelper

    included do
      if respond_to?(:helper_method)
        helper_method :repository_config_present
        helper_method :request_config_present
        helper_method :context_access_tab_repository
        helper_method :access_repository_contact
        helper_method :before_you_visit_note_present
        helper_method :context_access_tab_visit_note
        helper_method :highlight_terms
        helper_method :context_sidebar_containers_request
        helper_method :item_requestable?
        helper_method :paragraph_separator
        helper_method :link_to_name_facet
      end
    end

    def repository_config_present(_, document)
      document.repository_config.present?
    end

    def item_requestable?(_, options)
      document = options[:document]
      request_config_present('', document) && document.containers.present?
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

    def highlight_terms(args)
      safe_join(args[:value].map { |value| content_tag(:span, value, class: 'bg-info') })
    end

    def context_sidebar_containers_request(args)
      document = args[:document]
      presenter = Arclight::ShowPresenter.new(document, view_context)
      ApplicationController.renderer.render(
        'arclight/requests/_google_form',
        layout: false,
        locals: {
          google_form: Arclight::Requests::GoogleForm.new(document, presenter, solr_document_url(document))
        }
      )
    end

    def paragraph_separator(args)
      safe_join(args[:value].map { |paragraph| content_tag(:p, paragraph) })
    end

    def link_to_name_facet(args)
      options = args[:config].try(:separator_options) || {}
      values = args[:value] || []

      values.map do |value|
        view_context.link_to(
          value,
          view_context.search_action_path(f: { names_ssim: [value] })
        )
      end.to_sentence(options).html_safe
    end
  end
end
