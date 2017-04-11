require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

load 'tasks/arclight.rake'

require 'engine_cart/rake_task'

task default: :ci
