# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::DocumentDownloads do
  subject(:downloads) { described_class.new(document) }

  let(:document) do
    SolrDocument.new(
      id: 'abc123',
      unitid_ssm: ['sample_unitid'],
      userestrict_ssm: ['The Terms of the Collection'],
      extent_ssm: ['42GB'], # This field does not typically hold file size, but for test purposes..
      level_ssm: ['collection'],
      ref_ssm: ['http://example.com/finding-aid.pdf'] # This field does not typically hold URLs, but for test purposes..
    )
  end

  describe '#files' do
    it 'returns an array of Arclight::DocumentDownloads::File objects' do
      expect(downloads.files.length).to eq 2
      expect(downloads.files).to be_all(Arclight::DocumentDownloads::File)
    end
  end

  context 'when disabled' do
    let(:document) do
      SolrDocument.new(
        id: 'abc123',
        unitid_ssm: ['not_a_real_unitid']
      )
    end

    it 'return an empty array of files' do
      described_class.instance_variable_set(:@config, nil)
      expect(downloads.files).to eq []
    end
  end

  describe 'Arclight::DocumentDownloads::File' do
    let(:file_params) { {} }
    let(:file) do
      described_class::File.new(
        type: 'pdf',
        data: { 'href' => 'http://example.com/sample.pdf', 'size' => '1.23MB' },
        document: document,
        **file_params
      )
    end

    it 'has accessors for type, size, and href' do
      expect(file.type).to eq 'pdf'
      expect(file.size).to eq '1.23MB'
      expect(file.href).to eq 'http://example.com/sample.pdf'
    end

    context 'when a size_accessor is provided for the size' do
      let(:file_params) do
        {
          data: {
            'size_accessor' => 'extent',
            'href' => 'http://example.com/finding-aid.pdf'
          }
        }
      end

      it 'gets the value of the accessor from the provided document for the size value' do
        expect(file.size).to eq '42GB'
      end
    end

    context 'when a template is provided for the href' do
      before do
        allow(document).to receive(:repository_config).and_return(
          Arclight::Repository.new(slug: 'the-repo-id')
        )
      end

      let(:file_params) do
        {
          data: {
            'size' => '1.23MB',
            'template' => 'http://example.com/%<repository_id>s/%<level>s/%<terms>s/download.pdf'
          }
        }
      end

      it 'interpolates custom mappings' do
        expect(file.href).to include '/the-repo-id/'
      end

      it 'interpolates requested accessors from the solr document' do
        expect(file.href).to include '/collection/'
      end

      it 'escapes values from the document for usage in a URL' do
        expect(file.href).to include '/The+Terms+of+the+Collection/'
      end

      context 'when the document value returns a URL' do
        let(:file_params) do
          {
            data: {
              'size' => '1.23MB',
              'template' => '%<reference>s'
            }
          }
        end

        it 'is not escaped' do
          expect(file.href).to eq 'http://example.com/finding-aid.pdf'
        end
      end
    end
  end

  describe '.config' do
    context 'when the downloads config. file cannot be read' do
      before do
        described_class.instance_variable_set(:@config, nil)
        allow(described_class).to receive(:config_filename).and_return('non-existent')
      end

      after do
        described_class.instance_variable_set(:@config, nil)
        allow(described_class).to receive(:config_filename).and_call_original
      end

      it 'returns empty configuration values' do
        expect(described_class.config).to eq({})
      end
    end
  end
end
