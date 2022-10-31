# frozen_string_literal: true

require 'arclight/version'
require 'arclight/engine'
require 'arclight/repository'
require 'arclight/year_range'

# :nodoc:
module Arclight
  autoload :Routes, 'arclight/routes'

  def self.deprecation
    @deprecation ||= ActiveSupport::Deprecation.new('2.0', 'Arclight')
  end
end
