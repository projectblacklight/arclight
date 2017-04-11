# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arclight/version'

Gem::Specification.new do |spec|
  spec.name          = 'arclight'
  spec.version       = Arclight::VERSION
  spec.authors       = ['Jack Reed']
  spec.email         = ['phillipjreed@gmail.com']

  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = 'https://github.com/sul-dlss/arclight'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
