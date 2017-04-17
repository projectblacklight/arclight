# frozen_string_literal: true

require 'blacklight'
require 'solr_ead'
require 'arclight/custom_document'
require 'arclight/custom_component'

module Arclight
  ##
  # This is the defining class for the Arclight Rails Engine
  class Engine < ::Rails::Engine
    initializer 'arclight.helpers' do
      ActionView::Base.send :include, ArclightHelper
    end
  end
end
