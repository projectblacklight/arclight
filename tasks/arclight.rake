# frozen_string_literal: true

require 'solr_wrapper'
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'
require 'arclight'

EngineCart.fingerprint_proc = EngineCart.rails_fingerprint_proc

desc 'Run test suite'
task ci: %w[arclight:generate] do
  SolrWrapper.wrap do |solr|
    solr.with_collection do
      Rake::Task['arclight:seed'].invoke
      within_test_app do
        ## Do stuff inside arclight app here
      end
      Rake::Task['spec'].invoke
    end
  end
end

namespace :arclight do
  desc 'Generate a test application'
  task generate: %w[engine_cart:generate]

  desc 'Run Solr and Blacklight for interactive development'
  task :server, %i[rails_server_args] do |_t, args|
    if File.exist? EngineCart.destination
      within_test_app do
        system 'bundle update'
      end
    else
      Rake::Task['engine_cart:generate'].invoke
    end

    print 'Starting Solr...'
    SolrWrapper.wrap do |solr|
      puts 'done.'
      solr.with_collection do
        Rake::Task['arclight:seed'].invoke
        within_test_app do
          system "bundle exec rails s #{args[:rails_server_args]}"
        end
      end
    end
  end

  desc 'Seed fixture data to Solr'
  task :seed do
    system('DIR=./spec/fixtures/ead rake arclight:index_dir')
  end
end
