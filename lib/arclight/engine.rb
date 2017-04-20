# frozen_string_literal: true

require 'blacklight'
require 'solr_ead'
require 'arclight/shared_indexing_behavior'
require 'arclight/custom_document'
require 'arclight/custom_component'

module Arclight
  ##
  # This is the defining class for the Arclight Rails Engine
  class Engine < ::Rails::Engine
    Arclight::Engine.config.catalog_controller_field_accessors = %i[
      summary_field access_field background_field scope_and_arrangement_field
    ]

    initializer 'arclight.fields' do
      Arclight::Engine.config.catalog_controller_field_accessors.each do |field|
        Blacklight::Configuration.define_field_access field
      end
    end

    initializer 'arclight.helpers' do
      ActionView::Base.send :include, ArclightHelper
    end
  end
end
