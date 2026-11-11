# frozen_string_literal: true

require 'solr_wrapper'
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'
require 'arclight'

class DependencyNotInstalled < StandardError; end

# Build with our opinionated defaults if none are provided.
rails_options = ENV.fetch('ENGINE_CART_RAILS_OPTIONS', '')
rails_options = "#{rails_options} -a propshaft" unless rails_options.match?(/-a\s|--asset-pipeline/)
rails_options = "#{rails_options} -j importmap" unless rails_options.match?(/-j\s|--javascript/)
rails_options = "#{rails_options} --css bootstrap" unless rails_options.match?(/--css/)
ENV['ENGINE_CART_RAILS_OPTIONS'] = rails_options

desc 'Run test suite'
task ci: %w[arclight:generate] do
  with_solr do
    Rake::Task['arclight:seed'].invoke
    within_test_app do
      system 'bin/rake spec:prepare'
    end
    Rake::Task['spec'].invoke
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

    with_solr do
      Rake::Task['arclight:seed'].invoke
      within_test_app do
        system "bin/dev #{args[:rails_server_args]}"
      end
    end
  end

  desc 'Seed fixture data to Solr'
  task :seed do
    puts 'Seeding index with data from spec/fixtures/ead...'
    Dir.glob('spec/fixtures/ead/*').each do |dir|
      next unless File.directory?(dir)

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

SOLR_CORE = 'blacklight-core'
SOLR_CORE_STATUS_URL = "http://127.0.0.1:8983/solr/admin/cores?action=STATUS&core=#{SOLR_CORE}&wt=json".freeze

# Runs the block with Solr available, choosing how to provide it:
#   - SOLR_ENV=docker-compose: Solr is already running (e.g. under `docker compose up`), so just yield
#   - Docker available (and SOLR_WRAPPER not set): start Solr with Docker Compose
#   - otherwise: download and run Solr with solr_wrapper
def with_solr(&)
  if ENV['SOLR_ENV'] == 'docker-compose'
    yield
  elsif use_docker_solr?
    with_docker_solr(&)
  else
    print 'Starting Solr...'
    SolrWrapper.wrap do |solr|
      puts 'done.'
      solr.with_collection(&)
    end
  end
end

# Use Docker for Solr when Docker Compose is installed and the daemon is running.
# Set SOLR_WRAPPER=true to force solr_wrapper instead.
def use_docker_solr?
  return false if ENV['SOLR_WRAPPER'].to_s.match?(/\A(1|true|yes)\z/i)

  quiet = { out: File::NULL, err: File::NULL }
  system('docker', 'compose', 'version', **quiet) && system('docker', 'info', **quiet)
end

def docker_compose(*cmd, **)
  system({ 'PWD' => Arclight::Engine.root.to_s }, 'docker', 'compose', *cmd, chdir: Arclight::Engine.root.to_s, **)
end

# Starts Solr with Docker Compose, yields once the core responds, and stops the
# container afterward unless it was already running before we started.
def with_docker_solr
  already_running = !`cd #{Arclight::Engine.root} && docker compose ps -q --status running solr 2>/dev/null`.strip.empty?

  puts 'Starting Solr with Docker...'
  raise 'Failed to start Solr with docker compose' unless already_running || docker_compose('up', '-d', 'solr')

  wait_for_solr
  yield
ensure
  docker_compose('stop', 'solr') if already_running == false
end

# True once the core has loaded. Raises if Solr reports the core failed to load
# (e.g. a schema class it can't find), so we fail fast with Solr's reason.
def solr_up?
  status = JSON.parse(Net::HTTP.get(URI(SOLR_CORE_STATUS_URL)))
  failure = status.dig('initFailures', SOLR_CORE)
  raise "Solr could not load the #{SOLR_CORE} core: #{failure}" if failure

  status.dig('status', SOLR_CORE, 'name') == SOLR_CORE
rescue SystemCallError, IOError, JSON::ParserError, Net::ReadTimeout, Net::OpenTimeout
  false
end

def wait_for_solr(timeout: 60)
  require 'net/http'
  require 'json'
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
  print 'Waiting for Solr...'
  until solr_up?
    raise "Solr core #{SOLR_CORE} was not ready within #{timeout}s" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline

    print '.'
    sleep 1
  end
  puts ' done.'
end
