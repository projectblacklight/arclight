# frozen_string_literal: true

module Arclight
  ##
  # A mixin intended to share indexing behavior between
  # the CustomDocument and CustomComponent classes
  module SharedIndexingBehavior
    # @see http://eadiva.com/2/unitdate/
    # Currently only handling normal attributes and YYYY or YYYY/YYYY formats
    def formatted_unitdate_for_range
      return if normal_unit_dates.blank?
      normal_unit_date = Array.wrap(normal_unit_dates).first
      start_date, end_date = normal_unit_date.split('/')
      return [start_date] if end_date.blank?
      (start_date..end_date).to_a
    end
  end
end
