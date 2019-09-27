# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight do
  it 'has a version number' do
    expect(Arclight::VERSION).not_to be nil
  end

  describe 'Custom CatalogController field accessors' do
    subject(:custom_fields) do
      Arclight::Engine.config.catalog_controller_field_accessors
    end

    it { expect(custom_fields).to include :summary_field, :access_field }
  end
end
