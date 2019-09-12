module Arclight
  module Requests
    class AeonExternalRequest
      def initialize(document, presenter)
        @document = document
        @presenter = presenter
        @config = document.repository_config.request_config_for_type('aeon_external_request_endpoint')
      end

      def url
        "#{@config['request_url']}/aeon.dll?Action=11&Type=200"
      end

      def form_mapping
        static_mappings.merge(dynamic_mappings)
      end

      def static_mappings
        @config['request_mappings']['static']
      end

      def dynamic_mappings
        mappings = {}
        @config['request_mappings']['accessor'].each_pair do | k, v |
          mappings[k] = @document.send(v.to_sym)
        end
        mappings
      end
    end
  end
end
