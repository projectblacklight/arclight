# frozen_string_literal: true

require 'spec_helper'
require 'arclight/missing_id_strategy'

RSpec.describe Arclight::MissingIdStrategy do
  subject(:strategy) { described_class.selected }

  it 'defaults to Arclight::HashAbsoluteXpath' do
    expect(strategy).to eq Arclight::HashAbsoluteXpath
  end
end
