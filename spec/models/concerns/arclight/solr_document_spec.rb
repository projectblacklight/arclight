# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::SolrDocument do
  let(:document) { SolrDocument.new }

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
end
