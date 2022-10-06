# frozen_string_literal: true

module Arclight
  # Custom presentation methods for show partial
  class ShowPresenter < Blacklight::ShowPresenter
    def heading
      document.normalized_title
    end

    def with_field_group(group)
      if block_given?
        old_group = field_group

        begin
          self.field_group = group
          yield
        ensure
          self.field_group = old_group if block_given?
        end
      else
        self.field_group = group
        self
      end
    end

    def fields_have_content?(field_accessor)
      with_field_group(field_accessor) do
        fields_to_render.any?
      end
    end

    private

    # @return [Hash<String,Configuration::Field>] all the fields for this index view
    def fields
      if field_group
        configuration["#{field_group}s"] || []
      else
        super
      end
    end

    attr_accessor :field_group

    def field_config(field)
      return super unless field_group

      fields.fetch(field) do
        if defined?(Blacklight::Configuration::NullDisplayField)
          # For Blacklight 8:
          Blacklight::Configuration::NullDisplayField.new(field)
        else
          # Blacklight 7
          Blacklight::Configuration::NullField.new(field)
        end
      end
    end
  end
end
