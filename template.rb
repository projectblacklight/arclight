# frozen_string_literal: true

gem 'arclight'

after_bundle do
  generate 'blacklight:install', '--devise'
  generate 'arclight:install', '-f'

  rake 'db:migrate'
end
