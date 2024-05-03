# frozen_string_literal: true

require 'arclight/exceptions'

module Arclight
  ##
  # A simple utility class to normalize identifiers
  class NormalizedId
    # Accepts unused kwargs from the ead2_config.rb id to_field directive
    # (:title and :repository) so that applications can provide a custom
    # id_normalizer class to traject to form the collection id from these attributes.
    def initialize(id, **_kwargs)
      @id = id
    end

    def to_s
      normalize
    end

    private

    attr_reader :id

    def normalize
      raise Arclight::Exceptions::IDNotFound if id.blank?

      id.strip.tr('.', '-')
    end
  end
end
