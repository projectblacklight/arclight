# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

load 'tasks/arclight.rake'

require 'engine_cart/rake_task'

task default: %i[rubocop ci]
