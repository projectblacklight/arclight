# frozen_string_literal: true

require 'blacklight'
require 'solr_ead'
require 'arclight/normalized_date'
require 'arclight/normalized_id'
require 'arclight/normalized_title'
require 'arclight/digital_object'
require 'arclight/shared_indexing_behavior'
require 'arclight/shared_terminology_behavior'
require 'arclight/custom_document'
require 'arclight/custom_component'
require 'arclight/solr_ead_indexer_ext'
require 'arclight/indexer'
require 'arclight/viewer'

module Arclight
  ##
  # This is the defining class for the Arclight Rails Engine
  class Engine < ::Rails::Engine
    config.viewer_class = Arclight::Viewers::OEmbed
    config.oembed_resource_exclude_patterns = [/\.pdf$/, /\.ppt$/]

    Arclight::Engine.config.catalog_controller_field_accessors = %i[
      summary_field
      access_field
      background_field
      related_field
      admin_info_field
      terms_field
      cite_field
      indexed_terms_field
      in_person_field
      component_field
      online_field
    ]

    initializer 'arclight.fields' do
      Arclight::Engine.config.catalog_controller_field_accessors.each do |field|
        Blacklight::Configuration.define_field_access field
      end
    end

    initializer 'arclight.helpers' do
      ActionView::Base.send :include, ArclightHelper
    end

    initializer 'arclight.views' do
      Blacklight::Configuration.default_values[:view].hierarchy
    end
  end
end
