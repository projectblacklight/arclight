# frozen_string_literal: true

require 'arclight/hash_absolute_xpath'

module Arclight
  ##
  # A class to configure a selected MissingIdStrategy.
  # Defaults to Arclight::HashAbsoluteXpath
  # This can be updated in an initializer to be any other class
  class MissingIdStrategy
    class << self
      attr_writer :selected

      def selected
        return Arclight::HashAbsoluteXpath unless defined? @selected

        @selected
      end
    end
  end
end
