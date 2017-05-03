# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Repository', type: :feature do
  before do # don't read from the default config/repositories.yml for tests
    ENV['REPOSITORY_FILE'] = 'spec/fixtures/config/repositories.yml'
  end

  context 'has an ActiveRecord like interface' do
    it '#all' do
      repos = Arclight::Repository.all
      expect(repos[0].slug).to eq 'slug_abc'
      expect(repos[1].slug).to eq 'slug_xyz'
    end
    it '#find_by' do
      expect(Arclight::Repository.find_by('slug_abc').slug).to eq 'slug_abc'
      expect(Arclight::Repository.find_by('slug_xyz').slug).to eq 'slug_xyz'
      expect(Arclight::Repository.find_by('not_there')).to be_nil
    end
  end

  context 'a single repository has data' do
    let(:repo) { Arclight::Repository.find_by('slug_abc') }

    it 'in a YAML file' do
      expect(repo.slug).to eq 'slug_abc'
      expect(repo.name).to eq 'ABC'
    end
    context 'fields' do
      it '#name' do
        expect(repo.name).to eq 'ABC'
      end
      it '#description' do
        expect(repo.description).to eq 'Lorem ipsum'
      end
      it '#building' do
        expect(repo.building).to eq 'My Building'
      end
      it '#address1' do
        expect(repo.address1).to eq 'My Street Address'
      end
      it '#address2' do
        expect(repo.address2).to eq 'My Extra Address'
      end
      it '#city' do
        expect(repo.city).to eq 'My City'
      end
      it '#state' do
        expect(repo.state).to eq 'My State'
      end
      it '#country' do
        expect(repo.country).to eq 'My Country'
      end
      it '#phone' do
        expect(repo.phone).to eq '123-456-7890'
      end
      it '#contact_info' do
        expect(repo.contact_info).to eq 'My Contact Info'
      end
      it '#thumbnail_url' do
        expect(repo.thumbnail_url).to eq 'http://example.com/thumbnail_ABC.jpg'
      end
    end
  end
  context 'a second repository has data' do
    let(:repo) { Arclight::Repository.find_by('slug_xyz') }

    it 'in a YAML file' do
      expect(repo.slug).to eq 'slug_xyz'
      expect(repo.name).to eq 'XYZ'
    end
  end
end
