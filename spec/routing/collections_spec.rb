# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Vanity collections route' do
  routes { Arclight::Engine.routes }
  it 'routes to collection search' do
    expect(get: '/collections').to route_to(
      'f' => { 'level' => ['Collection'] },
      controller: 'catalog',
      action: 'index'
    )
  end
end
