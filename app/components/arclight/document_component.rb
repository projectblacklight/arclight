# frozen_string_literal: true

module Arclight
  # Render a single document
  class DocumentComponent < Blacklight::DocumentComponent
    def initialize(presenter:, **kwargs) # rubocop:disable Lint/MissingSuper
      @presenter = presenter
      @kwargs = kwargs
    end

    attr_reader :presenter
    delegate :collection?, to: :presenter

    def call
      if collection?
        render CollectionComponent.new(presenter: presenter, **@kwargs)
      else
        render NonCollectionComponent.new(presenter: presenter, **@kwargs)
      end
    end
  end
end
