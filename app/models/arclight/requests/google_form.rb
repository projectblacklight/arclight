# frozen_string_literal: true

module Arclight
  module Requests
    ##
    # This object relies on the ability to respond to attributes passed in as
    # query parameters from the form mapping configuratino
    class GoogleForm
      attr_reader :document, :presenter, :document_url

      delegate :collection_name, :collection_creator, :eadid, :containers, to: :document

      ##
      # @param [SolrDocument] document
      # @param [Arclight::ShowPresenter] presenter
      # @param [String] document_url
      def initialize(document, presenter, document_url)
        @document = document
        @presenter = presenter
        @document_url = document_url
      end

      ##
      # Url of form to fill
      def url
        request_config['request_url']
      end

      ##
      # Converts mappings as a query url param into a Hash used for sending
      # messages and providing pre-filled form fields
      # "collection_name=entry.123" => { "collection_name" => "entry.123" }
      # @return [Hash]
      def form_mapping
        Rack::Utils.parse_nested_query(
          request_config['request_mappings']
        )
      end

      def title
        presenter.heading
      end

      def request_config
        document.repository_config&.request_config_for_type('google_form')
      end
    end
  end
end
