# frozen_string_literal: true

require 'solr_wrapper'
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'
require 'arclight'

EngineCart.fingerprint_proc = EngineCart.rails_fingerprint_proc

desc 'Run test suite'
task ci: ['arclight:generate'] do
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
  task generate: ['engine_cart:generate'] do
  end

  desc 'Run Solr and Blacklight for interactive development'
  task :server, [:rails_server_args] do |_t, args|
    if File.exist? EngineCart.destination
      within_test_app do
        system 'bundle update'
      end
    else
      Rake::Task['engine_cart:generate'].invoke
    end

    SolrWrapper.wrap do |solr|
      solr.with_collection do
        Rake::Task['arclight:seed'].invoke
        within_test_app do
          system "bundle exec rails s #{args[:rails_server_args]}"
        end
      end
    end
  end

  desc 'Index a document'
  task :index do
    ENV['SOLR_URL'] = 'http://127.0.0.1:8983/solr/blacklight-core'
    indexer = load_indexer
    indexer.update(ENV['FILE'])
  end

  desc 'Index a directory of documents'
  task :index_dir do
    ENV['SOLR_URL'] = 'http://127.0.0.1:8983/solr/blacklight-core'
    raise 'Please specify your directory, ex. DIR=<path/to/directory>' unless ENV['DIR']
    indexer = load_indexer
    Dir.glob(File.join(ENV['DIR'], '*')).each do |file|
      print "Indexing #{File.basename(file)}..."
      indexer.update(file) if File.extname(file) =~ /xml$/
      print "done.\n"
    end
  end

  desc 'Seed fixture data to Solr'
  task :seed do
    system('DIR=./spec/fixtures/ead rake arclight:index_dir')
  end
end

def load_indexer
  options = {
    document: Arclight::CustomDocument,
    component: Arclight::CustomComponent
  }
  SolrEad::Indexer.new(options)
end
