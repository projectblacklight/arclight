# frozen_string_literal: true

module ControllerLevelHelpers
  def search_state
    @search_state ||= Blacklight::SearchState.new(params, blacklight_config, controller)
  end

  def blacklight_configuration_context
    @blacklight_configuration_context ||= Blacklight::Configuration::Context.new(controller)
  end

  def blacklight_config
    CatalogController.blacklight_config
  end
end
