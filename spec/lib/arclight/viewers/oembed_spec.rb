# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Viewers::OEmbed do
  subject(:viewer) { described_class.new(document) }

  let(:document) do
    SolrDocument.new(
      digital_objects_ssm: [{ href: 'http://example.com' }.to_json]
    )
  end

  describe '#resources' do
    it "returns the document's digital objects" do
      viewer.resources.all? do |resource|
        expect(resource).to be_a Arclight::DigitalObject
      end
    end
  end

  describe '#embeddable?' do
    let(:document) do
      SolrDocument.new(
        digital_objects_ssm: [
          { href: 'http://example.com/content.pdf' }.to_json,
          { href: 'http://example.com' }.to_json
        ]
      )
    end

    it 'is false when url matches exclude patterns' do
      expect(viewer.embeddable?(document.digital_objects.first)).to be false
    end

    it 'is true when url does not match exclude patterns' do
      expect(viewer.embeddable?(document.digital_objects.last)).to be true
    end
  end

  describe '#attributes_for' do
    let(:document) do
      SolrDocument.new(
        digital_objects_ssm: [
          { href: 'http://example.com/content.pdf' }.to_json,
          { href: 'http://example.com' }.to_json
        ]
      )
    end

    it 'returns a hash with oembed information' do
      attributes = viewer.attributes_for(document.digital_objects.last)
      expect(attributes[:'data-arclight-oembed']).to eq true
    end

    it 'returns an empty hash for non-embeddable objects' do
      attributes = viewer.attributes_for(document.digital_objects.first)
      expect(attributes).to be_empty
    end
  end

  describe '#to_partial_path' do
    it 'supplies a customized path' do
      expect(viewer.to_partial_path).to eq 'arclight/viewers/_oembed'
    end
  end
end
