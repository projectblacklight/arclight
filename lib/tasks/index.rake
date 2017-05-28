# frozen_string_literal: true

require 'arclight'
require 'benchmark'

##
# Environment variables for indexing:
#
# REPOSITORY_ID for the repository id/slug to load repository data from
# your configuration (default: none).
#
# REPOSITORY_FILE for the YAML file of your repository configuration
# (default: config/repositories.yml).
#
# SOLR_URL for the location of your Solr instance
# (default: http://127.0.0.1:8983/solr/blacklight-core)
#
namespace :arclight do
  desc 'Index an EAD document, use FILE=<path/to/ead.xml> and REPOSITORY_ID=<myid>'
  task :index do
    raise 'Please specify your EAD document, ex. FILE=<path/to/ead.xml>' unless ENV['FILE']
    indexer = load_indexer
    print "Loading #{ENV['FILE']} into index...\n"
    elapsed_time = Benchmark.realtime { indexer.update(ENV['FILE']) }
    print "Indexed #{ENV['FILE']} (in #{elapsed_time.round(3)} secs).\n"
  end

  desc 'Index a directory of EADs, use DIR=<path/to/directory> and REPOSITORY_ID=<myid>'
  task :index_dir do
    raise 'Please specify your directory, ex. DIR=<path/to/directory>' unless ENV['DIR']
    Dir.glob(File.join(ENV['DIR'], '*.xml')).each do |file|
      system("rake arclight:index FILE=#{file}")
    end
  end

  desc 'Index an EAD document, use URL=<http[s]://domain/path/to/ead.xml> and REPOSITORY_ID=<myid>'
  task :index_url do
    raise 'Please specify your EAD document, ex. URL=<http[s]://domain/path/to/ead.xml>' unless ENV['URL']
    ead = Nokogiri::XML(open(ENV['URL']))
    tmp = Tempfile.new(["#{Time.now.to_i}-", '.xml'], encoding: 'utf-8')
    begin
      tmp.write ead
      puts "Downloaded EAD to #{tmp.path}"
      ENV['FILE'] = tmp.path
      Rake::Task['arclight:index'].invoke
      Rake::Task['arclight:index'].reenable
      tmp.close
    ensure
      tmp.delete
    end
  end

  desc 'Index EADs from a file of URLs, use BATCH=<path/to/urls.txt> and REPOSITORY_ID=<myid>'
  task :index_url_batch do
    raise 'Please specify your URLs file, ex. BATCH=<path/to/urls.txt>' unless ENV['BATCH']
    File.open(ENV['BATCH']).each_line do |l|
      ENV['URL'] = l.chomp
      next if ENV['URL'].empty?
      unless ENV['URL'] =~ /\A#{URI.regexp(%w[http https])}\z/
        puts "Skipping invalid looking url #{ENV['URL']}"
        next
      end
      puts "Indexing #{ENV['URL']}"
      Rake::Task['arclight:index_url'].invoke
      Rake::Task['arclight:index_url'].reenable
    end
  end

  desc 'Destroy all documents in the index'
  task :destroy_index_docs do
    puts 'Deleting all documents from index...'
    indexer = load_indexer
    indexer.delete_all
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
