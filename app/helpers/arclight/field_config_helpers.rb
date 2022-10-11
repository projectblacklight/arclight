# frozen_string_literal: true

module Arclight
  ##
  # A module to add configuration helpers for certain fields used by Arclight
  module FieldConfigHelpers
    include Arclight::EadFormatHelpers

    def item_requestable?(document)
      document.repository_config&.request_types&.any?
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
