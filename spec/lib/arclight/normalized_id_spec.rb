# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::NormalizedId do
  subject(:normalized_id) { described_class.new(id).to_s }

  context 'when the id as a period in it' do
    let(:id) { 'abc123.xml' }

    it 'replaces it with a hyphen' do
      expect(normalized_id).to eq 'abc123-xml'
    end
  end

  context 'when the id has extra space in it' do
    let(:id) { '    abc123    ' }

    it 'is stripped' do
      expect(normalized_id).to eq 'abc123'
    end
  end

  context 'when the id is nil' do
    let(:id) { nil }

    it do
      expect { normalized_id }.to raise_error(
        Arclight::Exceptions::IDNotFound,
        'id must be present for all documents and components'
      )
    end
  end

  context 'when additional keyword arguments are supplied' do
    subject(:normalized_id) do
      described_class.new('abc123.xml', unitid: 'abc-123', title: 'a title', repository: 'repo').to_s
    end

    it 'accepts the additional arguments without changing the output' do
      expect(normalized_id).to eq 'abc123-xml'
    end
  end
end
