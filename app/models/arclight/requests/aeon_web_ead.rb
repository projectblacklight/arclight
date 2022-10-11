# frozen_string_literal: true

module Arclight
  module Requests
    ##
    # This object relies on the ability to respond to attributes passed in as
    # query parameters from the form mapping configuration
    class AeonWebEad
      attr_reader :document, :ead_url

      ##
      # @param [SolrDocument] document
      # @param [String] ead_url
      def initialize(document, ead_url)
        @document = document
        @ead_url = ead_url
      end

      ##
      # Url target for Aeon request params
      def request_url
        request_config['request_url']
      end

      ##
      # Constructed request URL
      def url
        "#{request_url}?#{form_mapping.to_query}"
      end

      ##
      # Converts mappings as a query url param into a Hash used for sending
      # messages
      # If a defined method is provided as a value, that method will be invoked
      # "collection_name=entry.123" => { "collection_name" => "entry.123" }
      # @return [Hash]
      def form_mapping
        form_hash = Rack::Utils.parse_nested_query(
          request_config['request_mappings']
        )
        form_hash.each do |key, value|
          respond_to?(value) && form_hash[key] = send(value)
        end
        form_hash
      end

      def request_config
        document.repository_config.request_config_for_type('aeon_web_ead')
      end
    end
  end
end
