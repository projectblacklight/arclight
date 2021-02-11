# -*- encoding: utf-8 -*-
# stub: arclight 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "arclight".freeze
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Darren Hardy".freeze, "Jessie Keck".freeze, "Gordon Leacock".freeze, "Jack Reed".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-02-11"
  s.description = "".freeze
  s.email = ["drh@stanford.edu".freeze, "jessie.keck@gmail.com".freeze, "gordonl@umich.edu".freeze, "phillipjreed@gmail.com".freeze]
  s.files = [".all-contributorsrc".freeze, ".babelrc".freeze, ".codeclimate.yml".freeze, ".eslintrc".freeze, ".gitignore".freeze, ".rspec".freeze, ".rubocop.yml".freeze, ".rubocop_todo.yml".freeze, ".solr_wrapper".freeze, ".travis.yml".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "Gemfile".freeze, "LICENSE.txt".freeze, "README.md".freeze, "Rakefile".freeze, "app/assets/images/blacklight/bookmark.svg".freeze, "app/assets/images/blacklight/collection.svg".freeze, "app/assets/images/blacklight/compact.svg".freeze, "app/assets/images/blacklight/container.svg".freeze, "app/assets/images/blacklight/ead.svg".freeze, "app/assets/images/blacklight/file.svg".freeze, "app/assets/images/blacklight/folder.svg".freeze, "app/assets/images/blacklight/list.svg".freeze, "app/assets/images/blacklight/logo.png".freeze, "app/assets/images/blacklight/minus.svg".freeze, "app/assets/images/blacklight/online.svg".freeze, "app/assets/images/blacklight/pdf.svg".freeze, "app/assets/images/blacklight/plus.svg".freeze, "app/assets/images/blacklight/repository.svg".freeze, "app/assets/javascripts/arclight/arclight.js".freeze, "app/assets/javascripts/arclight/collection_navigation.js".freeze, "app/assets/javascripts/arclight/collection_scrollspy.js".freeze, "app/assets/javascripts/arclight/context_navigation.js".freeze, "app/assets/javascripts/arclight/oembed_viewer.js".freeze, "app/assets/javascripts/arclight/truncator.js.erb".freeze, "app/assets/stylesheets/arclight/application.scss".freeze, "app/assets/stylesheets/arclight/bootstrap_overrides.scss".freeze, "app/assets/stylesheets/arclight/modules/collection_search.scss".freeze, "app/assets/stylesheets/arclight/modules/context_navigation.scss".freeze, "app/assets/stylesheets/arclight/modules/hierarchy_and_online_contents.scss".freeze, "app/assets/stylesheets/arclight/modules/highlights.scss".freeze, "app/assets/stylesheets/arclight/modules/layout.scss".freeze, "app/assets/stylesheets/arclight/modules/mastheads.scss".freeze, "app/assets/stylesheets/arclight/modules/repositories.scss".freeze, "app/assets/stylesheets/arclight/modules/repository_card.scss".freeze, "app/assets/stylesheets/arclight/modules/search_results.scss".freeze, "app/assets/stylesheets/arclight/modules/show_collection.scss".freeze, "app/assets/stylesheets/arclight/responsive.scss".freeze, "app/assets/stylesheets/arclight/variables.scss".freeze, "app/controllers/arclight/repositories_controller.rb".freeze, "app/controllers/concerns/arclight/ead_format_helpers.rb".freeze, "app/controllers/concerns/arclight/field_config_helpers.rb".freeze, "app/factories/blacklight_field_configuration_factory.rb".freeze, "app/helpers/arclight_helper.rb".freeze, "app/models/arclight/document_downloads.rb".freeze, "app/models/arclight/parent.rb".freeze, "app/models/arclight/parents.rb".freeze, "app/models/arclight/requests/aeon_external_request.rb".freeze, "app/models/arclight/requests/aeon_web_ead.rb".freeze, "app/models/arclight/requests/google_form.rb".freeze, "app/models/concerns/arclight/catalog.rb".freeze, "app/models/concerns/arclight/search_behavior.rb".freeze, "app/models/concerns/arclight/solr_document.rb".freeze, "app/presenters/arclight/index_presenter.rb".freeze, "app/presenters/arclight/show_presenter.rb".freeze, "app/views/arclight/.keep".freeze, "app/views/arclight/_requests.html.erb".freeze, "app/views/arclight/repositories/_in_person_repository.html.erb".freeze, "app/views/arclight/repositories/_repository.html.erb".freeze, "app/views/arclight/repositories/_repository_contact.html.erb".freeze, "app/views/arclight/repositories/index.html.erb".freeze, "app/views/arclight/repositories/show.html.erb".freeze, "app/views/arclight/requests/_aeon_external_request_endpoint.html.erb".freeze, "app/views/arclight/requests/_aeon_web_ead.html.erb".freeze, "app/views/arclight/requests/_google_form.html.erb".freeze, "app/views/arclight/viewers/_oembed.html.erb".freeze, "app/views/catalog/_access_contents.html.erb".freeze, "app/views/catalog/_arclight_abstract_or_scope.html.erb".freeze, "app/views/catalog/_arclight_bookmark_control.html.erb".freeze, "app/views/catalog/_arclight_document_header_icon.html.erb".freeze, "app/views/catalog/_arclight_document_index_header.html.erb".freeze, "app/views/catalog/_arclight_document_index_header_hierarchy_default.html.erb".freeze, "app/views/catalog/_arclight_document_index_header_online_contents_default.html.erb".freeze, "app/views/catalog/_arclight_index_compact_default.html.erb".freeze, "app/views/catalog/_arclight_index_default.html.erb".freeze, "app/views/catalog/_arclight_index_group_document_compact_default.html.erb".freeze, "app/views/catalog/_arclight_index_group_document_default.html.erb".freeze, "app/views/catalog/_arclight_online_content_indicator.html.erb".freeze, "app/views/catalog/_arclight_rangelimit.html.erb".freeze, "app/views/catalog/_arclight_viewer_default.html.erb".freeze, "app/views/catalog/_collection_contents.html.erb".freeze, "app/views/catalog/_collection_context.html.erb".freeze, "app/views/catalog/_collection_context_nav.html.erb".freeze, "app/views/catalog/_collection_online_contents.html.erb".freeze, "app/views/catalog/_component_context.html.erb".freeze, "app/views/catalog/_containers.html.erb".freeze, "app/views/catalog/_context_card.html.erb".freeze, "app/views/catalog/_context_sidebar.html.erb".freeze, "app/views/catalog/_custom_metadata.html.erb".freeze, "app/views/catalog/_document_downloads.html.erb".freeze, "app/views/catalog/_group.html.erb".freeze, "app/views/catalog/_group_header_compact_default.html.erb".freeze, "app/views/catalog/_group_header_default.html.erb".freeze, "app/views/catalog/_group_toggle.html.erb".freeze, "app/views/catalog/_home.html.erb".freeze, "app/views/catalog/_index_breadcrumb_default.html.erb".freeze, "app/views/catalog/_index_collection_context_default.html.erb".freeze, "app/views/catalog/_index_default.html.erb".freeze, "app/views/catalog/_index_header.html.erb".freeze, "app/views/catalog/_index_header_online_contents_default.html.erb".freeze, "app/views/catalog/_index_online_contents_default.html.erb".freeze, "app/views/catalog/_online_content_label.html.erb".freeze, "app/views/catalog/_search_form.html.erb".freeze, "app/views/catalog/_search_results.html.erb".freeze, "app/views/catalog/_search_results_repository.html.erb".freeze, "app/views/catalog/_show_actions_box_default.html.erb".freeze, "app/views/catalog/_show_breadcrumbs_default.html.erb".freeze, "app/views/catalog/_show_collection.html.erb".freeze, "app/views/catalog/_show_default.html.erb".freeze, "app/views/catalog/_show_upper_metadata_collection.html.erb".freeze, "app/views/catalog/_show_upper_metadata_default.html.erb".freeze, "app/views/catalog/_sort_and_per_page.html.erb".freeze, "app/views/catalog/_within_collection_dropdown.html.erb".freeze, "app/views/catalog/index.html.erb".freeze, "app/views/layouts/catalog_result.html.erb".freeze, "app/views/shared/_breadcrumbs.html.erb".freeze, "app/views/shared/_context_sidebar.html.erb".freeze, "app/views/shared/_header_navbar.html.erb".freeze, "app/views/shared/_main_menu_links.html.erb".freeze, "app/views/shared/_show_breadcrumbs.html.erb".freeze, "arclight.gemspec".freeze, "bin/console".freeze, "bin/rails".freeze, "bin/setup".freeze, "config/i18n-tasks.yml".freeze, "config/locales/arclight.en.yml".freeze, "config/repositories.yml".freeze, "config/routes.rb".freeze, "lib/arclight.rb".freeze, "lib/arclight/digital_object.rb".freeze, "lib/arclight/engine.rb".freeze, "lib/arclight/exceptions.rb".freeze, "lib/arclight/hash_absolute_xpath.rb".freeze, "lib/arclight/level_label.rb".freeze, "lib/arclight/missing_id_strategy.rb".freeze, "lib/arclight/normalized_date.rb".freeze, "lib/arclight/normalized_id.rb".freeze, "lib/arclight/normalized_title.rb".freeze, "lib/arclight/repository.rb".freeze, "lib/arclight/traject/ead2_config.rb".freeze, "lib/arclight/traject/nokogiri_namespaceless_reader.rb".freeze, "lib/arclight/version.rb".freeze, "lib/arclight/viewer.rb".freeze, "lib/arclight/viewers/oembed.rb".freeze, "lib/arclight/year_range.rb".freeze, "lib/generators/arclight/install_generator.rb".freeze, "lib/generators/arclight/templates/arclight.js".freeze, "lib/generators/arclight/templates/arclight.scss".freeze, "lib/generators/arclight/templates/catalog_controller.rb".freeze, "lib/generators/arclight/templates/config/downloads.yml".freeze, "lib/generators/arclight/templates/config/repositories.yml".freeze, "lib/generators/arclight/update_generator.rb".freeze, "lib/tasks/index.rake".freeze, "package.json".freeze, "solr/conf/_rest_managed.json".freeze, "solr/conf/admin-extra.html".freeze, "solr/conf/elevate.xml".freeze, "solr/conf/mapping-ISOLatin1Accent.txt".freeze, "solr/conf/protwords.txt".freeze, "solr/conf/schema.xml".freeze, "solr/conf/scripts.conf".freeze, "solr/conf/solrconfig.xml".freeze, "solr/conf/spellings.txt".freeze, "solr/conf/stopwords.txt".freeze, "solr/conf/stopwords_en.txt".freeze, "solr/conf/synonyms.txt".freeze, "solr/conf/xslt/example.xsl".freeze, "solr/conf/xslt/example_atom.xsl".freeze, "solr/conf/xslt/example_rss.xsl".freeze, "solr/conf/xslt/luke.xsl".freeze, "tasks/arclight.rake".freeze, "template.rb".freeze, "vendor/assets/javascripts/responsiveTruncator.js".freeze, "vendor/assets/javascripts/stickyfill.js".freeze]
  s.homepage = "https://github.com/sul-dlss/arclight".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<blacklight>.freeze, ["~> 7.2"])
      s.add_runtime_dependency(%q<blacklight_range_limit>.freeze, ["~> 7.1"])
      s.add_runtime_dependency(%q<rails>.freeze, ["~> 5.0"])
      s.add_runtime_dependency(%q<sprockets-bumble_d>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<traject>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<traject_plus>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<bundler>.freeze, ["> 1.14"])
      s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_development_dependency(%q<engine_cart>.freeze, [">= 0"])
      s.add_development_dependency(%q<i18n-tasks>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.74.0"])
      s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 1.35"])
      s.add_development_dependency(%q<selenium-webdriver>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<solr_wrapper>.freeze, [">= 0"])
      s.add_development_dependency(%q<webdrivers>.freeze, [">= 0"])
    else
      s.add_dependency(%q<blacklight>.freeze, ["~> 7.2"])
      s.add_dependency(%q<blacklight_range_limit>.freeze, ["~> 7.1"])
      s.add_dependency(%q<rails>.freeze, ["~> 5.0"])
      s.add_dependency(%q<sprockets-bumble_d>.freeze, [">= 0"])
      s.add_dependency(%q<traject>.freeze, ["~> 3.0"])
      s.add_dependency(%q<traject_plus>.freeze, ["~> 1.2"])
      s.add_dependency(%q<bundler>.freeze, ["> 1.14"])
      s.add_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_dependency(%q<engine_cart>.freeze, [">= 0"])
      s.add_dependency(%q<i18n-tasks>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.74.0"])
      s.add_dependency(%q<rubocop-rspec>.freeze, ["~> 1.35"])
      s.add_dependency(%q<selenium-webdriver>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<solr_wrapper>.freeze, [">= 0"])
      s.add_dependency(%q<webdrivers>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<blacklight>.freeze, ["~> 7.2"])
    s.add_dependency(%q<blacklight_range_limit>.freeze, ["~> 7.1"])
    s.add_dependency(%q<rails>.freeze, ["~> 5.0"])
    s.add_dependency(%q<sprockets-bumble_d>.freeze, [">= 0"])
    s.add_dependency(%q<traject>.freeze, ["~> 3.0"])
    s.add_dependency(%q<traject_plus>.freeze, ["~> 1.2"])
    s.add_dependency(%q<bundler>.freeze, ["> 1.14"])
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_dependency(%q<engine_cart>.freeze, [">= 0"])
    s.add_dependency(%q<i18n-tasks>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.74.0"])
    s.add_dependency(%q<rubocop-rspec>.freeze, ["~> 1.35"])
    s.add_dependency(%q<selenium-webdriver>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<solr_wrapper>.freeze, [">= 0"])
    s.add_dependency(%q<webdrivers>.freeze, [">= 0"])
  end
end
