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

    it '#find_by!(slug)' do
      expect(described_class.find_by!(slug: 'sample').slug).to eq 'sample'
      expect { described_class.find_by!(slug: 'not_there') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it '#find_by!(name)' do
      expect(described_class.find_by!(name: 'My Repository').slug).to eq 'sample'
      expect { described_class.find_by!(name: 'not_there') }.to raise_error(ActiveRecord::RecordNotFound)
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
    end
    context 'methods' do
      it '#request_config_present?' do
        expect(repo.request_config_present?).to be true
      end

      it '#request_config_present_for_type? is present' do
        expect(repo.request_config_present_for_type?('google_form')).to be true
      end

      it '#request_config_present_for_type? is not present' do
        expect(repo.request_config_present_for_type?('fake_type')).to be false
      end

      it '#request_url_for_type' do
        expect(repo.request_url_for_type('google_form')).to eq 'https://docs.google.com/abc123'
      end

      it '#request_mappings_for_type' do
        expect(repo.request_mappings_for_type('google_form')).to eq 'collection_name=abc&eadid=123'
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

  context 'the repositories.yml template for the generator is valid' do
    let(:repositories_yml_template_file) do
      SPEC_ROOT.parent + 'lib/generators/arclight/templates/config/repositories.yml'
    end

    it 'successfully loads the template repositories file' do
      nlm = described_class.find_by(slug: 'nlm', yaml_file: repositories_yml_template_file)
      expect(nlm.city).to eq 'Bethesda'
    end

    it 'has new-style request_type' do
      raw_yaml_hash = YAML.safe_load(File.read(repositories_yml_template_file))
      nlm = described_class.find_by(slug: 'nlm', yaml_file: repositories_yml_template_file)
      google_form_url = nlm.request_url_for_type('google_form')
      expect(google_form_url).to eq raw_yaml_hash['nlm']['request_types']['google_form']['request_url']
    end
  end

  describe 'extension' do
    let(:repo) { described_class.find_by(slug: 'sample') }

    it 'is possible' do
      expect(repo.downstream_defined_field).to eq 'Custom Data From Consumer'
    end
  end

  describe '#available_request_types' do
    context 'request types present' do
      let(:repo) { described_class.find_by(slug: 'sample') }

      it 'returns a list' do
        expect(repo.available_request_types).to eq ['google_form']
      end
    end

    context 'no request types' do
      let(:repo) { described_class.find_by(slug: 'sample-noreq') }

      it 'returns an empty array' do
        expect(repo.available_request_types).to eq []
      end
    end
  end
end
