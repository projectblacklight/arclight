# frozen_string_literal: true

module Arclight
  module Traject
    # Traject indexing macros specific to ArcLight
    module Macros
      def format_tags
        @xslt ||= Nokogiri::XSLT(File.read(File.join(File.expand_path('..', __dir__), 'traject', 'ead_formatting.xsl')))

        proc do |_record, accumulator|
          accumulator.map! do |element|
            doc = Nokogiri::XML::Document.new
            doc.root = element
            value = @xslt.transform(doc).serialize.strip
            value
          end
        end
      end
    end
  end
end
