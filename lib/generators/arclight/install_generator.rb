# frozen_string_literal: true

require 'rails/generators'

module Arclight
  ##
  # Arclight install generator
  class Install < Rails::Generators::Base # rubocop:disable Metrics/ClassLength
    source_root File.expand_path('templates', __dir__)

    class_option :test, type: :boolean, default: false, aliases: '-t', desc: 'Indicates that app will be installed in a test environment'

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

      Bundler.with_unbundled_env do
        run 'bundle install'
      end

      generate 'blacklight:locale_picker:install'

      inject_into_file 'app/helpers/application_helper.rb', after: 'include Blacklight::LocalePicker::LocaleHelper' do
        "\n\n  def additional_locale_routing_scopes\n    [blacklight, arclight_engine]\n  end"
      end
    end

    def add_custom_routes
      inject_into_file 'config/routes.rb', after: "mount Blacklight::Engine => '/'" do
        "\n  mount Arclight::Engine => '/'\n"
      end

      gsub_file 'config/routes.rb', 'root to: "catalog#index"', 'root to: "arclight/repositories#index"'
    end

    def add_frontend
      if ENV['CI']
        run "yarn add file:#{Arclight::Engine.root}"
      elsif options[:test]
        run 'yarn link arclight'

      # If a branch was specified (e.g. you are running a template.rb build
      # against a test branch), use the latest version available on npm
      elsif ENV['BRANCH']
        run 'yarn add arclight@latest'

      # Otherwise, pick the version from npm that matches the Arclight
      # gem version
      else
        run "yarn add arclight@#{arclight_yarn_version}"
      end
    end

    def add_stylesheets
      copy_file 'arclight.scss', 'app/assets/stylesheets/arclight.scss'
      append_to_file 'app/assets/stylesheets/application.bootstrap.scss' do
        <<~CONTENT
          @import "arclight";
        CONTENT
      end
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

    def add_i18n_config
      copy_file 'config/locales/arclight.en.yml'
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

    def inject_arclight_routes
      inject_into_file 'config/routes.rb',
                       "  concern :hierarchy, Arclight::Routes::Hierarchy.new\n",
                       after: /concern :exportable.*\n/
      inject_into_file 'config/routes.rb',
                       "  concerns :hierarchy\n",
                       after: /resources :solr_documents.*\n/
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
        pin "arclight", to: "arclight/arclight.js"
        # TODO: We may be able to move these to a single importmap for arclight.
        pin "arclight/oembed_controller", to: "arclight/oembed_controller.js"
        pin "arclight/truncate_controller", to: "arclight/truncate_controller.js"
      RUBY
    end

    def import_arclight_javascript
      append_to_file 'app/javascript/application.js', "\nimport \"arclight\""
    end

    def package_yarn_version(package_name, requested_version)
      versions = JSON.parse(`yarn info #{package_name} versions --json`)['data']
      exact_match = versions.find { |v| v == requested_version }
      return exact_match if exact_match

      major_version = Gem::Version.new(requested_version).segments.first
      "^#{major_version}"
    end

    def arclight_yarn_version
      package_yarn_version('arclight', Arclight::VERSION)
    end
  end
end
