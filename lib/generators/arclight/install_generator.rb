require 'rails/generators'

module Arclight
  ##
  # Arclight install generator
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def todo
      # add installation components here
    end
  end
end
