# frozen_string_literal: true

require 'arclight/viewers/oembed'

module Arclight
  ##
  # Arclight::Viewer provides the ability to render a configured viewer
  # The viewer class is configured through the Arclight::Engine configuration
  # which allows an application to implement their own viewer class.
  # This class will receive a SolrDocument and must implement to_partial_path.
  # See Arclight::Viewers::OEmbed for an example implementation of a viewer.
  class Viewer
    def self.render(document)
      new(document).render
    end

    def initialize(document)
      @document = document
    end

    def render
      renderer.render(
        viewer_instance.to_partial_path,
        layout: false,
        locals: { viewer: viewer_instance }
      )
    end

    private

    attr_reader :document

    def viewer_instance
      viewer_class.new(document)
    end

    def viewer_class
      Arclight::Engine.config.viewer_class
    end

    def renderer
      ApplicationController.renderer
    end
  end
end
