# frozen_string_literal: true

module Arclight
  ##
  # Arclight specific methods for the Catalog
  module Catalog
    extend ActiveSupport::Concern

    included do
      before_action only: :index do
        if (params.dig(:f, :collection) || []).any?(&:blank?)
          params[:f][:collection].compact_blank!
          params[:f].delete(:collection) if params[:f][:collection].blank?
        end
      end

      before_action only: :hierarchy do
        blacklight_config.search_state_fields += %i[id limit offset]
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

    def hierarchy
      @response = search_service.search_results
    end

    # Overrides blacklight search state so we can exclude some parameters from being passed into the SearchState
    def search_state
      @search_state ||= search_state_class.new(params.except('hierarchy', 'nest_path'), blacklight_config, self)
    end
  end
end
