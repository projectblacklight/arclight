# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Vanity collections route', type: :routing do
  routes { Arclight::Engine.routes }
  it 'routes to collection search' do
    expect(get: '/collections').to route_to(
      'f' => { 'level_sim' => ['Collection'] },
      controller: 'catalog',
      action: 'index'
    )
  end
end
