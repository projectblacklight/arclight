# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'arclight/repositories/index', type: :view do
  let(:test_data) { Arclight::Repository.all }

  before do
    ENV['REPOSITORY_FILE'] = 'spec/fixtures/config/repositories.yml'
    assign(:repositories, test_data)
    render
  end
  describe 'renders the three repository examples' do
    it 'has the header class' do
      expect(rendered).to have_css('.al-repositories', count: 1)
    end
    it 'has the four sections' do
      expect(rendered).to have_css('.al-repository', count: 4)
      %w[thumbnail contact description extra].each do |f|
        expect(rendered).to have_css(".al-repository-#{f}", count: 4)
      end
    end
    it 'has the correct location/contact information' do
      %w[building address1 city_state_zip_country phone contact_info].each do |f|
        expect(rendered).to have_css(".al-repository-contact-#{f}", count: 4)
      end
    end
    it 'handles a missing address2' do
      expect(rendered).to have_css('.al-repository-contact-address2', count: 3)
    end
  end
end
