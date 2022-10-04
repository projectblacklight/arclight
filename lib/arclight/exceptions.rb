# frozen_string_literal: true

module Arclight
  module Exceptions
    # Id's must be present on all documents and components
    class IDNotFound < StandardError
      def message
        'id must be present for all documents and components'
      end
    end

    # Unittitle or unitdate must be present on all documents and components
    class TitleNotFound < StandardError
      def message
        '<unittitle/> or <unitdate/> must be present for all documents and components'
      end
    end
  end
end
