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

    def add_custom_routes
      inject_into_file 'config/routes.rb', after: "mount Blacklight::Engine => '/'" do
        "\n    mount Arclight::Engine => '/'\n"
      end

      gsub_file 'config/routes.rb', 'root to: "catalog#index"', 'root to: "arclight/repositories#index"'
    end

    def copy_styles
      copy_file 'arclight.scss', 'app/assets/stylesheets/arclight.scss'
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

    def assets
      if using_importmap?
        pin_javascript_dependencies
        import_arclight_javascript
      else
        install_javascript_dependencies
      end
    end

    private

    def root
      @root ||= Pathname(destination_root)
    end

    def using_importmap?
      @using_importmap ||= root.join('config/importmap.rb').exist?
    end

    # This is the last step because any failure here wouldn't prevent the other steps from running
    def install_javascript_dependencies
      inject_into_file 'app/assets/javascripts/application.js', after: '//= require blacklight/blacklight' do
        "\n// Required by Arclight" \
          "\n//= require arclight/arclight"
      end
    end

    def pin_javascript_dependencies
      say 'Arclight Importmap asset generation'

      append_to_file 'config/importmap.rb', <<~RUBY
        pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.0/dist/jquery.js"
        pin "arclight", to: "arclight/arclight.js"
        # TODO: We may be able to move these to a single importmap for arclight.
        pin "arclight/collection_navigation", to: "arclight/collection_navigation.js"
        pin "arclight/context_navigation", to: "arclight/context_navigation.js"
        pin "arclight/oembed_viewer", to: "arclight/oembed_viewer.js"
        pin "arclight/truncator", to: "arclight/truncator.js"
        pin "arclight/responsiveTruncator", to: "arclight/responsiveTruncator.js"
      RUBY
    end

    def import_arclight_javascript
      inject_into_file 'app/javascript/application.js', after: 'import "blacklight"' do
        "\n  import $ from \"jquery\"\n  " \
          "window.$ = $ // required by arclight\n  " \
          "window.jQuery = $ // required by arclight/responsive_truncator.js\n  " \
          'import "arclight"'
      end
    end
  end
end
