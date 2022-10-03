# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::DigitalObject do
  subject(:instance) do
    described_class.new(label: 'An object label', href: 'https://example.com/an-object-href')
  end

  describe 'label' do
    let(:empty_label) do
      described_class.new(label: '', href: 'https://example.com/an-object-href')
    end

    it 'uses href if label is blank' do
      expect(empty_label.href).to eq 'https://example.com/an-object-href'
    end
  end

  describe '#to_json' do
    it 'returns a json serialization of the object' do
      json = JSON.parse(instance.to_json)
      expect(json).to be_a Hash
      expect(json['label']).to eq 'An object label'
    end
  end

  describe "#{described_class}.from_json" do
    it 'returns an instance of the class given the parsed json' do
      deserialized = described_class.from_json(instance.to_json)
      expect(deserialized).to be_a described_class
      expect(deserialized.label).to eq 'An object label'
    end
  end

  describe '==' do
    let(:dissimilar) do
      described_class.new(label: 'A different label', href: 'https://example.com/an-object-href')
    end

    let(:similar) do
      described_class.new(label: 'An object label', href: 'https://example.com/an-object-href')
    end

    it 'is true when href and label are similar' do
      expect(instance).not_to eq dissimilar
    end

    it 'is false when objects have dissimilar labels' do
      expect(instance).to eq similar
    end
  end
end
