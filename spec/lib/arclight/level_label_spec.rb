# frozen_string_literal: true

require 'spec_helper'
require 'arclight/level_label'

RSpec.describe Arclight::LevelLabel do
  subject(:level_label) { described_class.new(level, other_level).to_s }

  context 'when level is collection' do
    let(:level) { 'collection' }
    let(:other_level) { nil }

    it 'capitalizes it' do
      expect(level_label).to eq 'Collection'
    end
  end

  context 'when level has a custom human-readable value defined' do
    let(:level) { 'recordgrp' }
    let(:other_level) { nil }

    it 'uses the human-readable form' do
      expect(level_label).to eq 'Record Group'
    end
  end

  context 'when level is otherlevel & one is specified' do
    let(:level) { 'otherlevel' }
    let(:other_level) { 'binder' }

    it 'capitalizes specified value' do
      expect(level_label).to eq 'Binder'
    end
  end

  context 'when level is otherlevel without one specified' do
    let(:level) { 'otherlevel' }
    let(:other_level) { nil }

    it 'uses Other' do
      expect(level_label).to eq 'Other'
    end
  end
end
