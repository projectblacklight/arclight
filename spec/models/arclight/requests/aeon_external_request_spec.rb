# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Requests::AeonExternalRequest do
  subject(:valid_object) { described_class.new(document, {}) }

  let(:config_hash) do
    {
      'request_url' => 'https://example.com/aeon/aeon.dll',
      'request_mappings' => {
        'url_params' => {
          'Action' => 11,
          'Type' => 200
        },
        'static' => {
          'SystemId' => 'ArcLight',
          'ItemInfo1' => 'manuscript'
        },
        'accessor' => {
          'ItemTitle' => 'collection_name'
        }
      }
    }
  end

  let(:config) do
    instance_double Arclight::Repository,
                    request_config_for_type: config_hash
  end
  let(:document) do
    instance_double SolrDocument,
                    repository_config: config,
                    collection_name: 'Cool Document'
  end

  describe '#url' do
    it 'constructs from the repository config' do
      expect(valid_object.url).to eq 'https://example.com/aeon/aeon.dll?Action=11&Type=200'
    end
  end

  describe '#form_mapping' do
    it 'compiles from the repository config' do
      expect(valid_object.form_mapping).to eq('SystemId' => 'ArcLight',
                                              'ItemInfo1' => 'manuscript',
                                              'ItemTitle' => 'Cool Document')
    end
  end

  describe '#static_mappings' do
    it 'pulls from the repository config' do
      expect(valid_object.static_mappings).to eq('SystemId' => 'ArcLight',
                                                 'ItemInfo1' => 'manuscript')
    end
  end

  describe '#dynamic_mappings' do
    it 'pulls from the repository config' do
      expect(valid_object.dynamic_mappings).to eq('ItemTitle' => 'Cool Document')
    end
  end

  describe '#url_params' do
    it 'constructs from the repository config' do
      expect(valid_object.url_params).to eq('Action=11&Type=200')
    end
  end
end
