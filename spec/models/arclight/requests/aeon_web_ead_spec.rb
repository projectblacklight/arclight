# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Requests::AeonWebEad do
  subject(:valid_object) { described_class.new(document, 'http://example.com/sample.xml') }

  let(:config) do
    instance_double Arclight::Repository,
                    request_config_for_type: {
                      request_url: 'https://sample.request.com',
                      request_mappings: 'Action=10&Form=31&Value=ead_url'
                    }.with_indifferent_access
  end
  let(:document) { instance_double SolrDocument, repository_config: config }

  describe '#request_url' do
    it 'returns from the repository config' do
      expect(valid_object.request_url).to eq 'https://sample.request.com'
    end
  end

  describe '#url' do
    it 'constructs a url with params' do
      expect(valid_object.url).to eq 'https://sample.request.com?Action=10&Form=31&Value=http%3A%2F%2Fexample.com%2Fsample.xml'
    end
  end

  describe '#form_mapping' do
    subject(:form_mapping) { valid_object.form_mapping }

    it 'converts string from config to hash' do
      expect(form_mapping).to be_an Hash
    end

    it 'has valid key/value pairs' do
      expect(form_mapping).to include('Action' => '10', 'Form' => '31', 'Value' => 'http://example.com/sample.xml')
    end
  end
end
