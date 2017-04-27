# frozen_string_literal: true

require 'rails/generators'

module Arclight
  ##
  # Arclight install generator
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def create_blacklight_catalog
      remove_file 'app/controllers/catalog_controller.rb'
      copy_file 'catalog_controller.rb', 'app/controllers/catalog_controller.rb'
    end

    def include_arclight_solrdocument
      inject_into_file 'app/models/solr_document.rb', after: 'include Blacklight::Solr::Document' do
        "\n include Arclight::SolrDocument"
      end
    end

    def install_blacklight_range_limit
      generate 'blacklight_range_limit:install'
    end

    def add_custom_routes
      inject_into_file 'config/routes.rb', after: "mount Blacklight::Engine => '/'" do
        "\n    mount Arclight::Engine => '/'\n"
      end
    end

    def assets
      copy_file 'arclight.scss', 'app/assets/stylesheets/arclight.scss'
      copy_file 'arclight.js', 'app/assets/javascripts/arclight.js'
      inject_into_file 'app/assets/javascripts/application.js', after: '//= require blacklight/blacklight' do
        "\n//= require bootstrap/scrollspy\n" \
        "\n//= require bootstrap/tab\n"
      end
    end
  end
end
