# frozen_string_literal: true

module Arclight
  # Render various actions for a document (e.g. requesting, download links, etc)
  class DocumentActionsComponent < ViewComponent::Base
    delegate :document, to: :@presenter
    def initialize(presenter:)
      super

      @presenter = presenter
    end
  end
end
