# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Requests::GoogleForm do
  subject(:valid_object) { described_class.new(document, presenter, '') }

  let(:config) do
    instance_double Arclight::Repository,
                    request_config_for_type: { request_url: 'https://docs.google.com/abc123',
                                               request_mappings: 'collection_name=abc&eadid=123' }.with_indifferent_access
  end
  let(:document) { instance_double SolrDocument, repository_config: config }
  let(:presenter) { instance_double Arclight::ShowPresenter, heading: 'Indiana Jones and the Last Crusade' }

  describe 'API' do
    it 'responds to needed methods for mapping' do
      %i[collection_name eadid containers title].each do |method|
        expect(valid_object).to respond_to(method)
      end
    end
  end

  describe '#url' do
    it 'returns from the repository config' do
      expect(valid_object.url).to eq 'https://docs.google.com/abc123'
    end
  end

  describe '#form_mapping' do
    subject(:form_mapping) { valid_object.form_mapping }

    it 'converts string from config to hash' do
      expect(form_mapping).to be_an Hash
    end

    it 'has valid key/value pairs' do
      expect(form_mapping).to include('collection_name' => 'abc', 'eadid' => '123')
    end
  end

  describe '#title' do
    it 'gets the heading from the presenter' do
      expect(valid_object.title).to eq 'Indiana Jones and the Last Crusade'
    end
  end
end
