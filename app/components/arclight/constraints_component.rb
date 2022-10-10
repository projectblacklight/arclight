# frozen_string_literal: true

module Arclight
  # Extend the upstream constraints with breadcrumbs and
  # repository context information
  class ConstraintsComponent < Blacklight::ConstraintsComponent
    def initialize(**kwargs)
      super

      @kwargs = kwargs
    end

    def repository
      @repository ||= helpers.repository_faceted_on
    end
  end
end
