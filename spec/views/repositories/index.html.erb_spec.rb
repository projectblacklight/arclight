# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'arclight/repositories/index', type: :view do
  let(:test_data) { Arclight::Repository.all }

  before do
    ENV['REPOSITORY_FILE'] = 'spec/fixtures/config/repositories.yml'
    assign(:repositories, test_data)
  end

  context 'renders the three repository examples' do
    before { render }
    it 'has the header class' do
      expect(rendered).to have_css('.al-repositories', count: 1)
    end
    it 'has the four sections' do
      expect(rendered).to have_css('.al-repository', count: 4)
      %w[thumbnail contact description].each do |f|
        expect(rendered).to have_css(".al-repository-#{f}", count: 4)
      end
    end
    it 'has the correct address information' do
      %w[address1 city_state_zip_country].each do |f|
        expect(rendered).to have_css(".al-repository-street-address-#{f}", count: 4)
      end
    end
    it 'has the correct contact information' do
      %w[contact_info].each do |f|
        expect(rendered).to have_css(".al-repository-contact-info-#{f}", count: 4)
      end
    end
    it 'handles a missing building' do
      expect(rendered).to have_css('.al-repository-street-address-building', count: 3)
    end
    it 'handles a missing address2' do
      expect(rendered).to have_css('.al-repository-street-address-address2', count: 1)
    end
    it 'handles a missing phone' do
      expect(rendered).to have_css('.al-repository-contact-info-phone', count: 2)
    end
  end
  context 'switched extra content' do
    it 'shows on repositories page' do
      allow(view).to receive(:repositories_active?).and_return(true)
      render
      expect(rendered).to have_css('.al-repository-extra', count: 4)
    end
    it 'does not show on search page' do
      allow(view).to receive(:repositories_active?).and_return(false)
      render
      expect(rendered).not_to have_css('.al-repository-extra')
    end
  end
end
