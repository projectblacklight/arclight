# frozen_string_literal: true

require 'solr_wrapper'
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'
require 'arclight'

class DependencyNotInstalled < StandardError; end

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

desc 'Run Eslint'
task :eslint do
  raise DependencyNotInstalled, 'ESLint not found.  Please run yarn install.' unless File.exist?('./node_modules/.bin/eslint')

  exit 1 unless system './node_modules/.bin/eslint app/assets/javascripts'
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

    if ENV['SOLR_ENV'] == 'docker-compose'
      puts "Using docker solr"
      within_test_app do
        system "bundle exec rails s #{args[:rails_server_args]}"
      end
    elsif system('docker-compose -v')
      # We're not running docker-compose up but still want to use a docker instance of solr.
      begin
        puts "Starting Solr"
        system_with_error_handling "docker-compose up -d solr"
        within_test_app do
          system "bundle exec rails s #{args[:rails_server_args]}"
        end
      ensure
        puts "Stopping Solr"
        system_with_error_handling "docker-compose stop solr"
      end
    else
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
  end

  desc 'Seed fixture data to Solr'
  task :seed do
    puts 'Seeding index with data from spec/fixtures/ead...'
    Dir.glob('spec/fixtures/ead/*').each do |dir|
      next unless File.directory?(dir)

      if ENV['SOLR_ENV'] == 'docker-compose'
        within_test_app do
          # Sets the REPOSITORY_ID to the name of the file's containing directory
          system("REPOSITORY_ID=#{File.basename(dir)} " \
                 "REPOSITORY_FILE=#{Arclight::Engine.root}/spec/fixtures/config/repositories.yml " \
                 "DIR=#{Arclight::Engine.root}/#{dir} " \
                 "SOLR_URL=#{ENV['SOLR_URL']} " \
                 'rake arclight:index_dir')
        end
      else
        within_test_app do
          # Sets the REPOSITORY_ID to the name of the file's containing directory
          system("REPOSITORY_ID=#{File.basename(dir)} " \
                 "REPOSITORY_FILE=#{Arclight::Engine.root}/spec/fixtures/config/repositories.yml " \
                 "DIR=#{Arclight::Engine.root}/#{dir} " \
                 'SOLR_URL=http://127.0.0.1:8983/solr/blacklight-core ' \
                 'rake arclight:index_dir')
        end      
      end
    end
  end
end
