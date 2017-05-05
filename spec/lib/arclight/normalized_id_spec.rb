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

    it 'returns an empty string' do
      expect(normalized_id).to eq ''
    end
  end
end
