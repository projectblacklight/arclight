# frozen_string_literal: true

module Arclight
  module Requests
    ##
    # This object relies on the ability to respond to attributes passed in as
    # query parameters from the form mapping configuration
    class AeonWebEad
      attr_reader :document, :collection_downloads
      ##
      # @param [Blacklight::SolrDocument] document
      # @param [Arclight::ShowPresenter] presenter
      # @param [String] document_url
      def initialize(document, collection_downloads)
        @document = document
        @collection_downloads = collection_downloads
      end

      ##
      # Url of form to fill
      def url
        document.repository_config.request_url_for_type('aeon_web_ead')
      end

      def request_url
        "#{url}?#{form_mapping.to_query}"
      end

      def ead_url
        collection_downloads[:ead][:href]
      end

      ##
      # Converts mappings as a query url param into a Hash used for sending
      # messages and providing pre-filled form fields
      # "collection_name=entry.123" => { "collection_name" => "entry.123" }
      # @return [Hash]
      def form_mapping
        form_hash = Rack::Utils.parse_nested_query(
          document.repository_config.request_mappings_for_type('aeon_web_ead')
        )
        form_hash.each do |key, value|
          respond_to?(value) && form_hash[key] = send(value)
        end
        form_hash
      end

      def title
        presenter.heading
      end
    end
  end
end
