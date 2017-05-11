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

    context 'pattern blacklist' do
      let(:document) do
        SolrDocument.new(
          digital_objects_ssm: [{ href: 'http://example.com/content.pdf' }.to_json]
        )
      end

      it 'rejects urls that match the configured patterns' do
        expect(viewer.resources).to be_empty
      end
    end
  end

  describe '#to_partial_path' do
    it 'supplies a customized path' do
      expect(viewer.to_partial_path).to eq 'arclight/viewers/_oembed'
    end
  end
end
