# frozen_string_literal: true

# We can remove `blacklight` and `blacklight_range_limit` once they are released
# since they are already dependents of Arclight (but we need to pin to particular branches)
gem 'blacklight', github: 'projectblacklight/blacklight'
gem 'blacklight_range_limit', github: 'projectblacklight/blacklight_range_limit', branch: 'blacklight-7'

gem 'arclight', github: 'sul-dlss/arclight'

run 'bundle install'

generate 'blacklight:install', '--devise'
generate 'arclight:install', '-f'

rake 'db:migrate'
