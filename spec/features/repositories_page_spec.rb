# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Repositores Page', type: :feature do
  it 'is navigabe from the home page' do
    visit '/'

    within '.al-homepage-masthead' do
      click_link 'Repositories'
    end

    within '.al-repositories' do
      expect(page).to have_css('.al-repository h2 a', text: 'My Repository')
    end
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

      expect(page).to have_css('.al-collection-count', text: '2 collections')
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
  end
end
