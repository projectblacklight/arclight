# frozen_string_literal: true

module Arclight
  ##
  # A module to add configuration helpers for certain fields used by Arclight
  module FieldConfigHelpers
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        helper_method :context_sidebar_digital_object
        helper_method :repository_config_present
        helper_method :request_config_present
        helper_method :context_sidebar_repository
        helper_method :before_you_visit_note_present
        helper_method :context_sidebar_visit_note
        helper_method :context_sidebar_containers_request
        helper_method :item_requestable?
      end
    end

    def context_sidebar_digital_object(args)
      document = args[:document]
      ApplicationController.renderer.render(
        'arclight/digital_objects/_sidebar_section',
        layout: false,
        locals: { digital_objects: document.digital_objects }
      )
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
        document.repository_config.google_request_url.present? &&
        document.repository_config.google_request_mappings.present?
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
  end
end
