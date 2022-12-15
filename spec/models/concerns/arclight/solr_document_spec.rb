# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::SolrDocument do
  let(:document) { SolrDocument.new(id: '123') }

  describe 'custom accessors' do
    it { expect(document).to respond_to(:parent_ids) }
    it { expect(document).to respond_to(:parent_labels) }
    it { expect(document).to respond_to(:eadid) }
  end

  describe '#repository_config' do
    let(:document) { SolrDocument.new(repository_ssm: 'My Repository') }

    it 'is an instance of Arclight::Repository' do
      expect(document.repository_config).to be_a Arclight::Repository
    end

    it 'finds the correct repository' do
      expect(document.repository_config.name).to eq document.repository
    end
  end

  describe '#repository_and_unitid' do
    let(:document) do
      SolrDocument.new(repository_ssm: 'Repository Name', unitid_ssm: 'MS 123')
    end

    it 'joins the repository and unitid with a colon' do
      expect(document.repository_and_unitid).to eq 'Repository Name: MS 123'
    end

    context 'when the document does not have a unitid' do
      let(:document) { SolrDocument.new(repository_ssm: 'Repository Name') }

      it 'just returns the "Repository Name"' do
        expect(document.repository_and_unitid).to eq 'Repository Name'
      end
    end
  end

  describe 'digital objects' do
    let(:document) do
      SolrDocument.new(
        digital_objects_ssm: [
          { href: 'http://example.com', label: 'Label 1' }.to_json,
          { href: 'http://another-example.com', label: 'Label 2' }.to_json
        ]
      )
    end

    describe '#digital_objects' do
      context 'when the document has a digital object' do
        it 'is array of DigitalObjects' do
          expect(document.digital_objects.length).to eq 2
          document.digital_objects.all? do |object|
            expect(object).to be_a Arclight::DigitalObject
          end
        end
      end

      context 'when the document does not have a digital object' do
        let(:document) { SolrDocument.new }

        it 'is a blank array' do
          expect(document.digital_objects).to be_blank
        end
      end
    end
  end

  describe '#normalize_title' do
    let(:document) { SolrDocument.new(normalized_title_ssm: 'My Title, 1990-2000') }

    it 'uses the normalized title from index-time' do
      expect(document.normalized_title).to eq 'My Title, 1990-2000'
    end
  end

  describe '#normalize_date' do
    let(:document) { SolrDocument.new(normalized_date_ssm: '1990-2000') }

    it 'uses the normalized date from index-time' do
      expect(document.normalized_date).to eq '1990-2000'
    end
  end

  describe '#containers' do
    let(:document) { SolrDocument.new(containers_ssim: ['box 1', 'folder 4-5']) }

    it 'uses our rules for joining' do
      expect(document.containers.join(', ')).to eq 'Box 1, Folder 4-5'
    end
  end

  describe '#terms' do
    let(:document) { SolrDocument.new(userestrict_html_tesm: 'Must use gloves with photos.') }

    it 'uses the self terms' do
      expect(document.terms).to eq 'Must use gloves with photos.'
    end
  end

  describe '#parent_restrictions' do
    let(:document) { SolrDocument.new(parent_access_restrict_tesm: 'No access.') }

    it 'uses the parent_restrictions' do
      expect(document.parent_restrictions).to eq 'No access.'
    end
  end

  describe '#parent_terms' do
    let(:document) { SolrDocument.new(parent_access_terms_tesm: 'Must use gloves with photos.') }

    it 'uses the parent_terms' do
      expect(document.parent_terms).to eq 'Must use gloves with photos.'
    end
  end

  describe '#collection' do
    let(:document) { SolrDocument.new(id: 'blah', collection: { docs: [{ id: 'abc123' }] }) }

    it 'creates a SolrDocument of the first parent document' do
      expect(document.collection).to be_an SolrDocument
      expect(document.collection.id).to eq 'abc123'
    end
  end

  describe '#highlights' do
    before { allow(document).to receive(:response).and_return(response) }

    context 'without any highlighting data at all' do
      let(:response) { { 'highlighting' => {} } }

      it 'handles gracefully' do
        expect(document.highlights).to be_falsey
      end
    end

    context 'without any highlighting hits for document' do
      let(:response) { { 'highlighting' => { document.id => {} } } }

      it 'handles gracefully' do
        expect(document.highlights).to be_falsey
      end
    end

    context 'with highlighting hits for document but wrong field' do
      let(:response) { { 'highlighting' => { document.id => { 'title' => %w[my hits] } } } }

      it 'handles gracefully' do
        expect(document.highlights).to be_falsey
      end
    end

    context 'with highlighting hits' do
      let(:response) { { 'highlighting' => { document.id => { 'text' => %w[my hits] } } } }

      it 'handles gracefully' do
        expect(document.highlights).to be_truthy
        expect(document.highlights.length).to eq 2
        expect(document.highlights.join).to eq 'myhits'
      end
    end
  end
end
