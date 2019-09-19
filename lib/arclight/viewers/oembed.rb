# frozen_string_literal: true

module Arclight
  module Viewers
    ##
    # A class to represent and render an oEmbed viewer.
    # This defines a partial to be rendered and can
    # apply any required logic to help map necessary
    # document attributes for viewer instantiation
    #
    # This viewer assumes that the resource itself is requestable
    # according the CORS policy of the site. This is because we
    # fetch the resource and look for a link[rel="alternate"] with
    # a type="application/json+oembed". Th oEmbed endpoint described
    # with that link tag should be an oEmbed RICH type, and return
    # the viewer HTML in the html key of the JSON response.
    class OEmbed
      attr_reader :document

      def initialize(document)
        @document = document
      end

      def resources
        document.digital_objects
      end

      def embeddable?(resource)
        resource == resources.first && embeddable_resources.include?(resource)
      end

      def attributes_for(resource)
        return {} unless embeddable?(resource)

        { class: 'al-oembed-viewer', 'data-arclight-oembed': true, 'data-arclight-oembed-url': resource.href }
      end

      def to_partial_path
        'arclight/viewers/_oembed'
      end

      private

      def exclude_patterns
        Arclight::Engine.config.oembed_resource_exclude_patterns
      end

      def embeddable_resources
        document.digital_objects.reject do |object|
          exclude_patterns.any? do |pattern|
            object.href =~ pattern
          end
        end
      end
    end
  end
end
