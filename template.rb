# frozen_string_literal: true

gem 'arclight', github: 'sul-dlss/arclight'
gem 'blacklight_range_limit', '~> 7.1'

run 'bundle install'

generate 'blacklight:install', '--devise'
generate 'arclight:install', '-f'

rake 'db:migrate'
