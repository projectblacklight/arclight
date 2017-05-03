# frozen_string_literal: true

require 'arclight'

namespace :arclight do
  desc 'Index a document'
  task :index do
    raise 'Please specify your file, ex. FILE=<path/to/file.xml>' unless ENV['FILE']
    indexer = load_indexer
    indexer.update(ENV['FILE'])
  end

  desc 'Index a directory of documents'
  task :index_dir do
    raise 'Please specify your directory, ex. DIR=<path/to/directory>' unless ENV['DIR']
    indexer = load_indexer
    Dir.glob(File.join(ENV['DIR'], '*.xml')).each do |file|
      print "Indexing #{File.basename(file)}..."
      indexer.update(file)
      print "done.\n"
    end
  end
end

def load_indexer
  # hardcoded since we don't have access to Blacklight.connection_config[:url] here
  ENV['SOLR_URL'] ||= 'http://127.0.0.1:8983/solr/blacklight-core'

  options = {
    document: Arclight::CustomDocument,
    component: Arclight::CustomComponent
  }

  Arclight::Indexer.new(options)
end
