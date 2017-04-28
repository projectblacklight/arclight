# frozen_string_literal: true

module Arclight
  ##
  # Arclight specific methods for the Catalog
  module Catalog
    ##
    # Overriding the Blacklight method so that the hierarchy view does not start
    # a new search session
    def start_new_search_session?
      params[:view] != 'hierarchy' && super
    end

    ##
    # Overriding the Blacklight method so that hierarchy does not get stored as
    # the preferred view
    def store_preferred_view
      return if params[:view] == 'hierarchy'
      super
    end
  end
end
