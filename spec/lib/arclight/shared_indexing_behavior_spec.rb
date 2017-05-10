# frozen_string_literal: true

require 'spec_helper'

class TestClass
  attr_accessor :normal_unit_dates
  include Arclight::SharedIndexingBehavior
end

RSpec.describe Arclight::SharedIndexingBehavior do
  subject(:indexer) { TestClass.new }

  context '#to_year_from_iso8601' do
    it 'blanks' do
      expect(indexer.to_year_from_iso8601(nil)).to be_nil
      expect(indexer.to_year_from_iso8601('   ')).to be_nil
    end
    it 'YYYY' do
      expect(indexer.to_year_from_iso8601('1999')).to eq 1999
    end
    it 'YYYY-MM' do
      expect(indexer.to_year_from_iso8601('1999-01')).to eq 1999
    end
    it 'YYYY-MM-DD' do
      expect(indexer.to_year_from_iso8601('1999-01-02')).to eq 1999
    end
    it 'YYYYMMDD' do
      expect(indexer.to_year_from_iso8601('19990102')).to eq 1999
    end
    it 'tiny years' do
      expect(indexer.to_year_from_iso8601('1')).to eq 1
    end
  end

  context '#to_date_range' do
    it 'blanks' do
      expect(indexer.to_date_range(nil)).to be_nil
      expect(indexer.to_date_range('   ')).to be_nil
    end
    it 'YYYY' do
      expect(indexer.to_date_range('1999')).to eq %w[1999]
    end
    it 'YYYY/YYYY' do
      expect(indexer.to_date_range('1999/2000')).to eq %w[1999 2000]
    end
    it 'too large YYYY/YYYY' do
      expect { indexer.to_date_range('1999/9999') }.to raise_error(RuntimeError, /unsupported/i)
    end
    it 'YYYY-MM/YYYY' do
      expect(indexer.to_date_range('1999-12/2000')).to eq %w[1999 2000]
    end
    it 'YYYY-MM-DD/YYYY' do
      expect(indexer.to_date_range('1999-12-31/2000')).to eq %w[1999 2000]
    end
    it 'YYYYMMDD/YYYY' do
      expect(indexer.to_date_range('19991231/2000')).to eq %w[1999 2000]
    end
  end

  context '#formatted_unitdate_for_range' do
    it 'single range' do
      indexer.normal_unit_dates = %w[1999/2000]
      expect(indexer.formatted_unitdate_for_range).to eq %w[1999 2000]
    end
    it 'multiple ranges will warn and only pick first' do
      indexer.normal_unit_dates = %w[1999/2000 2010/2011]
      expect($stdout).to receive(:puts).with(/warning.*unsupported/i) # rubocop: disable RSpec/MessageSpies
      expect(indexer.formatted_unitdate_for_range).to eq %w[1999 2000]
    end
    it 'bogus call' do
      indexer.normal_unit_dates = %w[]
      expect(indexer.formatted_unitdate_for_range).to be_nil
    end
  end
end
