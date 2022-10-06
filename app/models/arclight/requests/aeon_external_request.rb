# frozen_string_literal: true

module Arclight
  module Requests
    ##
    # This class should be used to turn configuration into a URL and
    # POST form specifically aimed at Aeon's external request
    # endpoint (https://support.atlas-sys.com/hc/en-us/articles/360011820054-External-Request-Endpoint)
    class AeonExternalRequest
      def initialize(document, presenter)
        @document = document
        @presenter = presenter
      end

      def config
        @config ||= @document.repository_config.request_config_for_type('aeon_external_request_endpoint')
      end

      def url
        "#{config['request_url']}?#{url_params}"
      end

      def form_mapping
        static_mappings.merge(dynamic_mappings)
      end

      def static_mappings
        config['request_mappings']['static']
      end

      def dynamic_mappings
        config['request_mappings']['accessor'].transform_values do |v|
          @document.public_send(v.to_sym)
        end
      end

      def url_params
        config['request_mappings']['url_params'].to_query
      end
    end
  end
end
