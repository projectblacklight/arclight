# frozen_string_literal: true

module Arclight
  ##
  # A utility class to normalize dates, typically by joining inclusive and bulk dates
  # e.g., "1990-2000, bulk 1990-1999"
  # @see http://www2.archivists.org/standards/DACS/part_I/chapter_2/4_date
  class NormalizedDate
    # @param [String | Array<String>] `inclusive` from the `unitdate`
    # @param [Array<String>] `bulk` from the `unitdate`
    # @param [Array<String>] `other` from the `unitdate` when type is not specified
    def initialize(inclusive, bulk = [], other = [])
      @inclusive = (inclusive || []).map do |inclusive_text|
        if inclusive_text.is_a? Array # of YYYY-YYYY for ranges
          # NOTE: This code is not routable AFAICT in actual indexing.
          # We pass arrays of strings (or xml nodes) here, and never a multidimensional array
          year_range(inclusive_text)
        elsif inclusive_text.present?
          inclusive_text.strip
        end
      end&.join(', ')

      @bulk = Array.wrap(bulk).compact.map(&:strip).join(', ')
      @other = Array.wrap(other).compact.map(&:strip).join(', ')
    end

    # @return [String] the normalized title/date
    def to_s
      normalize
    end

    private

    attr_reader :inclusive, :bulk, :other

    def year_range(date_array)
      YearRange.new(date_array.include?('/') ? date_array : date_array.map { |v| v.tr('-', '/') }).to_s
    end

    # @see http://www2.archivists.org/standards/DACS/part_I/chapter_2/4_date for rules
    def normalize
      if inclusive.present?
        result = inclusive.to_s
        result << ", bulk #{bulk}" if bulk.present?
      elsif other.present?
        result = other.to_s
      else
        result = nil
      end
      return if result.blank?
      result.strip
    end
  end
end
