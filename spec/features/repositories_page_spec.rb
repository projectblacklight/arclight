# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Repositores Page', type: :feature do
  it 'is navigabe from the home page' do
    visit '/'

    within '.al-repositories' do
      expect(page).to have_css('.al-repository h2 a', text: 'My Repository')
    end

    expect(page.body).to include('<title>Repositories - Arclight</title>')
  end

  describe 'Repostory Show Page' do
    it 'is navigable form the Repositories page' do
      visit '/repositories'

      click_link 'Stanford University Libraries. Special Collections and University Archives'

      expect(page).to have_css('h2', text: 'Our Collections')
    end

    it 'links to all the repositories collections' do
      visit '/repositories'

      click_link 'Stanford University Libraries. Special Collections and University Archives'

      click_link 'View all of our collections'

      expect(page).to have_css('h2', text: 'Search Results')
    end

    it 'does not link the same page in the repository card header' do
      visit '/repositories'

      click_link 'Stanford University Libraries. Special Collections and University Archives'

      within '.al-repository' do
        expect(page).not_to have_css(
          'h2 a',
          text: 'Stanford University Libraries. Special Collections and University Archives'
        )
      end
    end

    it 'has a title title starting with the repository name' do
      visit '/repositories'

      click_link 'Stanford University Libraries. Special Collections and University Archives'

      expect(page.body).to include('<title>Stanford University Libraries. Special Collections and University Archives - Arclight</title>')
    end
  end
end
