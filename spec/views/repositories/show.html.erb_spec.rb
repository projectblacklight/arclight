# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'arclight/repositories/show' do
  let(:test_data) { Arclight::Repository.find_by(slug: 'sample') }

  before do
    ENV['REPOSITORY_FILE'] = 'spec/fixtures/config/repositories.yml'
    assign(:repository, test_data)
    assign(:collections, [])
    allow(view).to receive(:search_action_url).and_return('/')
  end

  context 'renders a repository detail page' do
    before { render }

    it 'has the repository card' do
      expect(rendered).to have_css('.al-repository h2', text: /My Repository/)
    end

    it 'has breadcrumbs' do
      expect(rendered).to have_css('.al-search-breadcrumb', text: /My Repository/)
    end
  end
end
