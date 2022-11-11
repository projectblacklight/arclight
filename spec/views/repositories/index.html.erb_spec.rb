# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'arclight/repositories/index' do
  let(:test_data) { Arclight::Repository.all }

  before do
    ENV['REPOSITORY_FILE'] = 'spec/fixtures/config/repositories.yml'
    assign(:repositories, test_data)
    allow(view).to receive(:search_action_path).and_return('/')
    allow(view).to receive(:on_repositories_index?).and_return(true)
  end

  context 'renders the three repository examples' do
    before { render }

    it 'has the header class' do
      expect(rendered).to have_css('.al-repositories', count: 1)
    end

    it 'has the proper title' do
      within('.al-repository:nth-of-type(1)') do
        expect(rendered).to have_css('h2', text: /My Repository/)
        expect(rendered).to have_css('h2 a @href', text: '/repositories/sample')
      end
    end

    it 'has the four sections' do
      expect(rendered).to have_css('.al-repository', count: 5)
      %w[thumbnail contact description].each do |f|
        expect(rendered).to have_css(".al-repository-#{f}", count: 5)
      end
    end

    it 'has the correct address information' do
      %w[address1 city_state_zip_country].each do |f|
        expect(rendered).to have_css(".al-repository-street-address-#{f}", count: 4)
      end
    end

    it 'has the correct contact information' do
      expect(rendered).to have_css('.al-repository-contact-info a @href', count: 3, text: /mailto:/)
    end

    it 'handles a missing building' do
      expect(rendered).to have_css('.al-repository-street-address-building', count: 3)
    end

    it 'handles a missing address2' do
      expect(rendered).to have_css('.al-repository-street-address-address2', count: 1)
    end

    it 'handles a missing phone' do
      expect(rendered).to have_css('.al-repository-contact-phone', count: 2)
    end

    context 'collection counts' do
      it '0 collections' do
        within('.al-repository-extra-collection-count') do
          expect(rendered).to have_css('.al-repository-collection-count', text: 'No collections')
        end
      end

      it '1 collection' do
        within('.al-repository-extra-collection-count') do
          expect(rendered).to have_css('.al-repository-collection-count', text: '1 collection')
        end
      end

      it 'n collections' do
        within('.al-repository-extra-collection-count') do
          expect(rendered).to have_css('.al-repository-collection-count', text: '2 collections')
        end
      end
    end
  end

  context 'switched extra content' do
    it 'shows on repositories page' do
      render
      expect(rendered).to have_css('.al-repository-extra', count: 5)
    end

    it 'does not show on repositories detail page' do
      assign(:repository, Arclight::Repository.new(name: 'My Repository'))
      allow(view).to receive(:on_repositories_index?).and_return(false)
      render
      expect(rendered).not_to have_css('.al-repository-extra')
    end

    it 'does not show on search page' do
      allow(view).to receive(:on_repositories_index?).and_return(false)
      render
      expect(rendered).not_to have_css('.al-repository-extra')
    end
  end
end
