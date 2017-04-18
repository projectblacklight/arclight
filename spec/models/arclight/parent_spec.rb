# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Parent do
  subject(:instance) { described_class.new(id: 'abc', label: 'ABC', eadid: '123') }

  describe '#global_id' do
    it 'returns a correct global identifier' do
      expect(instance.global_id).to eq '123abc'
    end
  end
end
