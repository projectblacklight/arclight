require 'spec_helper'

RSpec.describe 'Arclight', type: :feature do
  it 'navigates to homepage' do
    visit '/'
    expect(page).to have_css 'h2', text: 'Welcome!'
  end
end
