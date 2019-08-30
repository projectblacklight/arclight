# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

Dir.glob('./tasks/*.rake').each { |f| load f }
Dir.glob('./lib/tasks/*.rake').each { |f| load f }

require 'engine_cart/rake_task'

task default: %i[rubocop eslint ci]
