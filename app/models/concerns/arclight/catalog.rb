# frozen_string_literal: true

module Arclight
  ##
  # Arclight specific methods for the Catalog
  module Catalog
    extend ActiveSupport::Concern

    included do
      before_action only: :index do
        if (params.dig(:f, :collection_sim) || []).any?(&:blank?)
          params[:f][:collection_sim].compact_blank!
          params[:f].delete(:collection_sim) if params[:f][:collection_sim].blank?
        end
      end

      Blacklight::Configuration.define_field_access :summary_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :background_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :related_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :indexed_terms_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :in_person_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :cite_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :contact_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :component_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :component_indexed_terms_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :terms_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :component_terms_field, Blacklight::Configuration::ShowField
      Blacklight::Configuration.define_field_access :group_header_field, Blacklight::Configuration::IndexField
    end

    ##
    # Overriding the Blacklight method so that the hierarchy view does not start
    # a new search session
    def start_new_search_session?
      %w[collection_context].exclude?(params[:view]) && super
    end

    ##
    # Overriding the Blacklight method so that hierarchy does not get stored as
    # the preferred view
    def store_preferred_view
      return if %w[collection_context].include?(params[:view])

      super
    end
  end
end
