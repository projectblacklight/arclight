# frozen_string_literal: true

module Arclight
  ##
  # A module to add configuration helpers for certain fields used by Arclight
  module FieldConfigHelpers
    include Arclight::EadFormatHelpers

    def item_requestable?(document)
      document.requestable?
    end
    Arclight.deprecation.deprecate_methods(self, item_requestable?: 'Call e.g. `document.requestable?` instead')

    def link_to_name_facet(args)
      options = args[:config]&.separator_options || {}
      values = args[:value] || []

      values.map do |value|
        link_to(
          value,
          search_action_path(f: { names: [value] })
        )
      end.to_sentence(options).html_safe
    end
  end
end
