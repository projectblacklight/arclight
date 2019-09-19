# frozen_string_literal: true

##
# A factory to return blacklight field configurations given a field key
# that represents a field group (e.g. summary_fields, access_fields, etc)
class BlacklightFieldConfigurationFactory
  def self.for(config:, field:, field_group:)
    new(config: config, field: field, field_group: field_group).field_config
  end

  def initialize(config:, field:, field_group:)
    @config = config
    @field = field
    @field_group = field_group
  end

  def field_config
    return null_field unless config.respond_to?(:"#{field_group}s")

    config.send(:"#{field_group}s").fetch(field) { null_field }
  end

  private

  attr_reader :config, :field, :field_group

  def null_field
    Blacklight::Configuration::NullField.new(field)
  end
end
