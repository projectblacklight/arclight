# frozen_string_literal: true

require 'blacklight'
require 'traject'
require 'active_model'
require 'arclight/exceptions'
require 'arclight/normalized_date'
require 'arclight/normalized_id'
require 'arclight/normalized_title'
require 'arclight/digital_object'
require 'arclight/viewer'
require 'blacklight_range_limit'

module Arclight
  ##
  # This is the defining class for the Arclight Rails Engine
  class Engine < ::Rails::Engine
    config.viewer_class = Arclight::Viewers::OEmbed
    config.oembed_resource_exclude_patterns = [/\.pdf$/, /\.ppt$/]

    Arclight::Engine.config.catalog_controller_field_accessors = %i[
      summary_field
      access_field
      contact_field
      background_field
      related_field
      terms_field
      cite_field
      indexed_terms_field
      in_person_field
      component_field
      online_field
      component_terms_field
      component_indexed_terms_field
    ]

    Arclight::Engine.config.catalog_controller_group_query_params = {
      group: true,
      'group.field': 'collection_ssi',
      'group.ngroups': true,
      'group.limit': 3,
      fl: '*,parent:[subquery]',
      'parent.fl': '*',
      'parent.q': '{!term f=collection_sim v=$row.collection_ssi}',
      'parent.fq': '{!term f=level_sim v="Collection"}',
      'parent.defType': 'lucene'
    }

    initializer 'arclight.fields' do
      Arclight::Engine.config.catalog_controller_field_accessors.each do |field|
        Blacklight::Configuration.define_field_access field
      end
    end

    initializer 'arclight.helpers' do
      config.after_initialize do
        ActionView::Base.send :include, ArclightHelper
      end
    end
  end
end
