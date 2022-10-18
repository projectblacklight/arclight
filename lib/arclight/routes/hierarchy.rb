# frozen_string_literal: true

module Arclight
  module Routes
    # Inject a hierarchy route for displaying the
    # components in the collection context
    class Hierarchy
      def initialize(defaults = {})
        @defaults = defaults
      end

      def call(mapper, _options = {})
        mapper.member do
          mapper.get 'hierarchy'
        end
      end
    end
  end
end
