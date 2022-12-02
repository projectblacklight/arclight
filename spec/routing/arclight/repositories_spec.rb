# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Vanity repositories routes' do
  routes { Arclight::Engine.routes }
  context 'repositories' do
    it '#index' do
      expect(get: '/repositories').to route_to(
        controller: 'arclight/repositories',
        action: 'index'
      )
    end

    it '#show' do
      expect(get: '/repositories/my-slug').to route_to(
        controller: 'arclight/repositories',
        action: 'show',
        id: 'my-slug'
      )
    end
  end
end
