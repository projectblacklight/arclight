# frozen_string_literal: true

module Arclight
  ##
  # A utility class to normalize dates, typically by joining inclusive and bulk dates
  # e.g., "1990-2000, bulk 1990-1999"
  # @see http://www2.archivists.org/standards/DACS/part_I/chapter_2/4_date
  class NormalizedDate
    # @param [Array<String>] an array of unitdate strings in order
    # @param [Array<String>] an array of corresponding type labels for dates or nil
    def initialize(unitdates, unitdate_labels)
      @date_accumulator = []
      if unitdates.present?
        unitdates.each_with_index do |unitdate, i|
          if unitdate_labels[i].downcase.match?('bulk')
            @date_accumulator << "#{unitdate_labels[i]} #{unitdate}"
          else
            @date_accumulator << unitdate
          end
        end
      end
    end

    # @return [String] the normalized title/date
    def to_s
      @date_accumulator.join(', ')
    end

    private

    attr_reader :inclusive, :bulk, :other

    def year_range(date_array)
      YearRange.new(date_array.include?('/') ? date_array : date_array.map { |v| v.tr('-', '/') }).to_s
    end
  end
end
