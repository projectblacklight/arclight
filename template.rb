# frozen_string_literal: true

gem 'blacklight', github: 'projectblacklight/blacklight'
gem 'arclight', github: 'sul-dlss/arclight'

run 'bundle install'

generate 'blacklight:install', '--devise'
generate 'arclight:install', '-f'

rake 'db:migrate'
