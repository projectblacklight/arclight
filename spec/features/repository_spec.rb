# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Repository', type: :feature do
  let(:test_data) { Arclight::Repository.from_yaml('spec/fixtures/config/repositories.yml') }

  context 'a single repository has data' do
    let(:repo) { test_data['slug_abc'] }

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
    let(:repo) { test_data['slug_xyz'] }

    it 'in a YAML file' do
      expect(repo.slug).to eq 'slug_xyz'
      expect(repo.name).to eq 'XYZ'
    end
  end
  context 'has an ActiveRecord like interface' do
    before do # we don't want to read from the normal config/ directory for tests...
      allow(Arclight::Repository).to receive(:from_yaml).with('config/repositories.yml').and_return(test_data)
    end
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
end
