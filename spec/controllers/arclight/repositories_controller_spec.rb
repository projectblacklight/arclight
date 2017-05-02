# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::RepositoriesController, type: :controller do
  routes { Arclight::Engine.routes }
  before do
    ENV['REPOSITORY_FILE'] = 'spec/fixtures/config/repositories.yml'
  end

  it 'displays the repositories' do
    get :index
    expect(response).to be_success
  end

  it 'assigns the view variable' do
    get :index
    repos = controller.instance_variable_get(:@repositories)
    expect(repos).to be_an(Array)
    expect(repos.first).to be_an(Arclight::Repository)
    expect(repos.size).to eq 4
  end
end
