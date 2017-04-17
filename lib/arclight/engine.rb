# frozen_string_literal: true

require 'blacklight'
require 'solr_ead'
require 'arclight/custom_document'
require 'arclight/custom_component'

module Arclight
  class Engine < ::Rails::Engine
    initializer 'arclight.helpers' do
      ActionView::Base.send :include, ArclightHelper
    end
  end
end
