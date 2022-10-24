# frozen_string_literal: true

require 'blacklight'
require 'traject'
require 'active_model'
require 'arclight/exceptions'
require 'arclight/normalized_date'
require 'arclight/normalized_id'
require 'arclight/normalized_title'
require 'arclight/digital_object'

module Arclight
  ##
  # This is the defining class for the Arclight Rails Engine
  class Engine < ::Rails::Engine
    config.oembed_resource_exclude_patterns = [/\.pdf$/, /\.ppt$/]

    Arclight::Engine.config.catalog_controller_group_query_params = {
      group: true,
      'group.field': '_root_',
      'group.ngroups': true,
      'group.limit': 3,
      fl: '*,collection:[subquery]',
      'collection.q': '{!terms f=id v=$row._root_}',
      'collection.defType': 'lucene',
      'collection.fl': '*',
      'collection.rows': 1
    }

    initializer 'arclight.helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include ArclightHelper }
      end
    end

    initializer 'arclight.assets', before: 'assets' do |app|
      app.config.assets.precompile << 'arclight/arclight.js'
      app.config.assets.precompile << 'arclight/oembed_viewer.js'
      app.config.assets.precompile << 'arclight/truncator.js'
    end
  end
end
