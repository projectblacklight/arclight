# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arclight/version'

Gem::Specification.new do |spec|
  spec.name          = 'arclight'
  spec.version       = Arclight::VERSION
  spec.authors       = ['Darren Hardy', 'Jessie Keck', 'Gordon Leacock', 'Jack Reed']
  spec.email         = ['drh@stanford.edu', 'jessie.keck@gmail.com', 'gordonl@umich.edu', 'phillipjreed@gmail.com']

  spec.summary       = 'A Blacklight-based environment to support discovery and delivery for archives and special collections'
  spec.description   = ''
  spec.homepage      = 'https://library.stanford.edu/projects/arclight'
  spec.metadata = { 'source_code_uri' => 'https://github.com/projectblacklight/arclight' }
  spec.license = 'Apache-2.0'

  spec.required_ruby_version = '>= 3.0.0'
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'blacklight', '>= 8.0.0', '< 9'
  spec.add_dependency 'gretel'
  spec.add_dependency 'rails', '~> 7.0'
  spec.add_dependency 'traject', '~> 3.0'
  spec.add_dependency 'traject_plus', '~> 2.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'engine_cart'
  spec.add_development_dependency 'i18n-tasks'
  spec.add_development_dependency 'rake', '>= 12.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop', '~> 1.8'
  spec.add_development_dependency 'rubocop-rails', '~> 2.8'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.3'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'solr_wrapper'
  spec.add_development_dependency 'webdrivers'
end
