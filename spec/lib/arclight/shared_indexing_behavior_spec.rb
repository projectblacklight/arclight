# frozen_string_literal: true

require 'spec_helper'

class TestClass
  attr_accessor :normal_unit_dates
  include Arclight::SharedIndexingBehavior
end

RSpec.describe Arclight::SharedIndexingBehavior do
  subject(:indexer) { TestClass.new }

  context '#unitdate_for_range' do
    it 'single range' do
      indexer.normal_unit_dates = %w[1999/2000]
      expect(indexer.unitdate_for_range.to_s).to eq '1999-2000'
    end
    it 'multiple ranges will warn and only pick first' do
      indexer.normal_unit_dates = %w[1999/2000 2010/2011]
      expect(indexer.unitdate_for_range.to_s).to eq '1999-2000, 2010-2011'
    end
    it 'bogus call' do
      indexer.normal_unit_dates = %w[]
      expect(indexer.unitdate_for_range.to_s).to be_nil
    end
  end
end
