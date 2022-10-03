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

    initializer 'arclight.helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include ArclightHelper }
      end
    end
  end
end
