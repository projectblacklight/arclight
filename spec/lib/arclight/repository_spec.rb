# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Repository do
  context 'has an ActiveRecord like interface' do
    it '#all' do
      repos = described_class.all
      expect(repos.map(&:slug)).to include 'sample', 'nlm', 'sul-spec'
    end
    it '#find_by(slug)' do
      expect(described_class.find_by(slug: 'sample').slug).to eq 'sample'
      expect(described_class.find_by(slug: 'not_there')).to be_nil
      expect { described_class.find_by(slug: nil) }.to raise_error(ArgumentError)
    end
    it '#find_by(name)' do
      expect(described_class.find_by(name: 'My Repository').slug).to eq 'sample'
      expect(described_class.find_by(name: 'not_there')).to be_nil
      expect { described_class.find_by(name: nil) }.to raise_error(ArgumentError)
    end
  end

  context 'a single repository has data' do
    let(:repo) { described_class.find_by(slug: 'sample') }

    it 'in a YAML file' do
      expect(repo.slug).to eq 'sample'
    end
    context 'fields' do
      it '#name' do
        expect(repo.name).to eq 'My Repository'
      end
      it '#visit_note' do
        expect(repo.visit_note).to eq 'Containers are stored offsite and must be pages 2 to 3 days in advance'
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
      it '#zip' do
        expect(repo.zip).to eq '12345'
      end
      it '#country' do
        expect(repo.country).to eq 'My Country'
      end
      it '#city_state_zip_country' do
        expect(repo.city_state_zip_country).to eq 'My City, My State 12345, My Country'
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
      it '#google_request_url' do
        expect(repo.google_request_url).to eq 'https://docs.google.com/abc123'
      end
      it '#google_request_mappings' do
        expect(repo.google_request_mappings).to eq 'collection_name=abc&eadid=123'
      end
    end
  end
  context 'a second repository has data' do
    let(:repo) { described_class.find_by(slug: 'nlm') }

    it 'in a YAML file' do
      expect(repo.slug).to eq 'nlm'
    end
  end
  context 'when missing data' do
    let(:repo) { described_class.find_by(slug: 'sample') }

    it 'handles missing a country' do
      repo.country = nil
      expect(repo.city_state_zip_country).to eq 'My City, My State 12345'
    end
  end
end
