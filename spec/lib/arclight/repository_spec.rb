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

      it '#location_html' do
        expect(repo.location).to be_html_safe
      end

      it '#contact' do
        expect(repo.contact).to be_html_safe
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
    end
  end

  context 'a second repository has data' do
    let(:repo) { described_class.find_by(slug: 'nlm') }

    it 'in a YAML file' do
      expect(repo.slug).to eq 'nlm'
    end
  end

  context 'the repositories.yml template for the generator is valid' do
    let(:repositories_yml_template_file) do
      Arclight::Engine.root.join('lib/generators/arclight/templates/config/repositories.yml')
    end

    it 'has new-style request_type' do
      raw_yaml_hash = YAML.safe_load(File.read(repositories_yml_template_file))
      nlm = described_class.find_by(slug: 'nlm', yaml_file: repositories_yml_template_file)
      google_form_url = nlm.request_config_for_type('google_form')['request_url']
      expect(google_form_url).to eq raw_yaml_hash['nlm']['request_types']['google_form']['request_url']
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
