# frozen_string_literal: true

require 'spec_helper'

describe BlacklightFieldConfigurationFactory, type: :factory do
  subject(:factory) do
    described_class.new(config: config, field: field, field_group: field_group)
  end

  let(:field) { 'creator_ssm' }
  let(:field_group) { 'summary_field' }
  let(:config) do
    Blacklight::Configuration.new do |config|
      config.add_summary_field 'creator_ssm', label: 'Creator', separator_options: { words_connector: '; ' }
    end
  end

  context 'a configured field' do
    it 'returns the configuration class for the given field' do
      expect(factory.field_config).to be_a Blacklight::Configuration::SummaryField
      expect(factory.field_config.separator_options).to eq(words_connector: '; ')
    end
  end

  context 'a field that has no configuration' do
    let(:field) { 'non_configured_field' }

    it 'returns a NullField config' do
      expect(factory.field_config).to be_a Blacklight::Configuration::NullField
    end
  end

  context 'a field group that is not configured' do
    let(:field_group) { 'non_configured_field_group' }

    it 'returns a NullField config' do
      expect(factory.field_config).to be_a Blacklight::Configuration::NullField
    end
  end
end
