# frozen_string_literal: true

module Arclight
  ##
  # A utility class to normalize titles, typically by joining
  # the title and date, e.g., "My Title, 1990-2000"
  class NormalizedTitle
    # @param [String] `title` from the `unittitle`
    # @param [String] `date` from the `unitdate`
    # @param [String] `default` the fallback for the title (e.g., an id)
    def initialize(title, date = nil, default = nil)
      @title = title.gsub(/\s*,\s*$/, '').strip if title.present?
      @date = date.strip if date.present?
      @default = default
    end

    # @return [String] the normalized title/date
    def to_s
      normalize
    end

    private

    attr_reader :title, :date, :default

    def normalize
      result = [title, date].compact.join(', ')
      return default.to_s if result.blank?
      result
    end
  end
end
