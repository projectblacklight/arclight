# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Vanity repositories route', type: :routing do
  routes { Arclight::Engine.routes }
  it 'routes to repositories display' do
    expect(get: '/repositories').to route_to(
      controller: 'arclight/repositories',
      action: 'index'
    )
  end
end
