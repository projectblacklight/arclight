# frozen_string_literal: true

module Arclight
  # Draws the repository breadcrumb item for a search result
  class RepositoryBreadcrumbComponent < ViewComponent::Base
    def initialize(document:)
      super
      @document = document
    end

    delegate :blacklight_icon, to: :helpers

    def repository_path
      @document.repository_config&.slug
    end
  end
end
