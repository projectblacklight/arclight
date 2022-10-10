# frozen_string_literal: true

module Arclight
  ##
  # Model the Download links that can be configured (via YAML) for a collection
  # or container
  class DocumentDownloads
    attr_reader :document

    def initialize(document, id = nil)
      @document = document
      @id = id
    end

    # Accessor for the ID
    # @return [String]
    def id
      @id || document.unitid
    end

    # Factory method for the File objects
    # @return [Array<Arclight::DocumentDownloads::File>]
    def files
      data = self.class.config[id] || self.class.config['default']
      disabled = data.delete('disabled')
      return [] if disabled

      @files ||= data.map do |file_type, file_data|
        self.class.file_class.new(type: file_type, data: file_data, document: document)
      end.compact
    end

    class << self
      def config
        @config ||= begin
          YAML.safe_load(::File.read(config_filename))
        rescue Errno::ENOENT
          {}
        end
      end

      def config_filename
        Rails.root.join('config/downloads.yml')
      end

      # Accessor for the File Class
      # @return [Class]
      def file_class
        Arclight::DocumentDownloads::File
      end
    end

    ##
    # Model a single file configured in downloads.yml
    class File
      attr_reader :type, :document

      def initialize(type:, data:, document:)
        @type = type
        @data = data
        @document = document
      end

      def href
        return data['href'] if data['href']

        format_template
      end

      def size
        return data['size'] if data['size']

        document.public_send(data['size_accessor'].to_sym) if data['size_accessor']
      end

      private

      attr_reader :data

      def format_template
        return unless template

        template % template_interpolations
      end

      def template
        data['template']
      end

      def template_interpolations
        escaped_document_interpolations.merge(custom_interpolations).symbolize_keys
      end

      def custom_interpolations
        { 'repository_id' => document.repository_config&.slug }
      end

      def template_variables
        template.scan(Regexp.union(/%{(\w+)}/, /%<(\w+)>/)).flatten.compact.uniq
      end

      def escaped_document_interpolations
        non_custom_template_variables.index_with do |method_name|
          escape_non_url_doc_value(document.public_send(method_name))
        end
      end

      def escape_non_url_doc_value(value)
        value = Array.wrap(value).first || '' # Handle single values/arrays and nil
        return value if value.start_with?(/https?:/)

        CGI.escape(value)
      end

      def non_custom_template_variables
        template_variables.reject do |v|
          custom_interpolations.keys.include?(v)
        end
      end
    end
  end
end
