# frozen_string_literal: true

require 'rails/generators'

module Arclight
  ##
  # Arclight install generator
  class Install < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_blacklight_catalog
      remove_file 'app/controllers/catalog_controller.rb'
      copy_file 'catalog_controller.rb', 'app/controllers/catalog_controller.rb'
    end

    def include_arclight_solrdocument
      inject_into_file 'app/models/solr_document.rb', after: 'include Blacklight::Solr::Document' do
        "\n include Arclight::SolrDocument"
      end
    end

    def install_blacklight_locale_picker
      gem 'blacklight-locale_picker'

      Bundler.with_clean_env do
        run 'bundle install'
      end

      generate 'blacklight:locale_picker:install'

      inject_into_file 'app/helpers/application_helper.rb', after: 'include Blacklight::LocalePicker::LocaleHelper' do
        "\n\n  def additional_locale_routing_scopes\n    [blacklight, arclight_engine]\n  end"
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

    def copy_styles
      copy_file 'arclight.scss', 'app/assets/stylesheets/arclight.scss'
    end

    def inject_js
      inject_into_file 'app/assets/javascripts/application.js', after: '//= require blacklight/blacklight' do
        "\n// Required by Arclight" \
        "\n//= require arclight/arclight"
      end
    end

    def install_webpacker
      return unless Rails.version.to_i == 6

      rake 'webpacker:install'
    end

    def add_arclight_search_behavior
      inject_into_file 'app/models/search_builder.rb', after: 'include Blacklight::Solr::SearchBuilderBehavior' do
        "\n  include Arclight::SearchBehavior"
      end
    end

    def solr_config
      directory '../../../../solr', 'solr', force: true
    end

    def add_repository_config
      copy_file 'config/repositories.yml' unless File.exist?('config/repositories.yml')
    end

    def add_download_config
      copy_file 'config/downloads.yml' unless File.exist?('config/downloads.yml')
    end

    def modify_blacklight_yml
      gsub_file 'config/locales/blacklight.en.yml', "application_name: 'Blacklight'", "application_name: 'Arclight'"
    end

    def run_yarn
      run 'yarn add @babel/core @babel/plugin-external-helpers @babel/plugin-transform-modules-umd @babel/preset-env'
    end
  end
end
