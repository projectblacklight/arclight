# frozen_string_literal: true

module Arclight
  ##
  # A utility class to return a human-readable label for an EAD @level code.
  # Can use the value from @otherlevel if provided.
  # Examples from @level: recordgrp = "Record Group"
  #                       collection = "Collection"
  #                       subseries = "Subseries"
  #                       otherlevel = (text provided in @otherlevel)
  class LevelLabel
    # @param [String] `level` from the collection or component @level
    # @param [String] `other_level` from the collection or component @otherlevel
    def initialize(level, other_level = nil)
      @level = level
      @other_level = other_level if other_level.present?
    end

    # @return [String] the human-readable label
    def to_s
      human_readable_level
    end

    private

    attr_reader :level, :other_level

    CUSTOM_LEVEL_LABELS = {
      recordgrp: 'Record Group',
      subgrp: 'Subgroup'
    }.freeze

    def human_readable_level
      if level == 'otherlevel'
        alternative_level
      elsif level.present?
        CUSTOM_LEVEL_LABELS.fetch(level.to_sym, level.capitalize).to_s
      end
    end

    def alternative_level
      alternative_level = other_level if other_level
      alternative_level.present? ? alternative_level.capitalize : 'Other'
    end
  end
end
