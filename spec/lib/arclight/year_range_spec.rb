# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::YearRange do
  subject(:range) { described_class.new }

  describe '#initialize' do
    it 'takes blanks' do
      expect(described_class.new.years.length).to eq 0
    end

    it 'takes ranges' do
      expect(described_class.new(%w[1999 2002/2003]).years.length).to eq 3
    end
  end

  describe '#to_year_from_iso8601' do
    it 'blanks' do
      expect(range.to_year_from_iso8601(nil)).to be_nil
      expect(range.to_year_from_iso8601('   ')).to be_nil
    end

    it 'YYYY' do
      expect(range.to_year_from_iso8601('1999')).to eq 1999
    end

    it 'YYYY-MM' do
      expect(range.to_year_from_iso8601('1999-01')).to eq 1999
    end

    it 'YYYY-MM-DD' do
      expect(range.to_year_from_iso8601('1999-01-02')).to eq 1999
    end

    it 'YYYYMM' do
      expect(range.to_year_from_iso8601('199901')).to eq 1999
    end

    it 'YYYYMMDD' do
      expect(range.to_year_from_iso8601('19990102')).to eq 1999
    end

    it 'tiny YYYY' do
      expect(range.to_year_from_iso8601('1')).to eq 1
    end
  end

  describe '#parse_range' do
    it 'blanks' do
      expect(range.parse_range(nil)).to be_nil
      expect(range.parse_range('   ')).to be_nil
    end

    it 'YYYY' do
      expect(range.parse_range('1999')).to eq((1999..1999).to_a)
    end

    it 'YYYY/YYYY' do
      expect(range.parse_range('1999/2000')).to eq((1999..2000).to_a)
    end

    it 'YYYY-MM/YYYY' do
      expect(range.parse_range('1999-12/2000')).to eq((1999..2000).to_a)
    end

    it 'YYYY-MM-DD/YYYY' do
      expect(range.parse_range('1999-12-31/2000')).to eq((1999..2000).to_a)
    end

    it 'YYYYMMDD/YYYY' do
      expect(range.parse_range('19991231/2000')).to eq((1999..2000).to_a)
    end

    it 'inverted YYYY/YYYY' do
      expect { range.parse_range('1999/1998') }.to raise_error(ArgumentError, /inverted/i)
    end

    it 'too large YYYY/YYYY' do
      expect { range.parse_range('1999/9999') }.to raise_error(ArgumentError, /too large/i)
    end
  end

  describe '#parse_ranges' do
    it 'empty call' do
      expect(range.parse_ranges([])).to be_empty
    end

    it 'single range' do
      expect(range.parse_ranges(%w[1999/2000])).to eq [1999, 2000]
    end

    it 'simple multiple ranges' do
      expect(range.parse_ranges(%w[1999/2000 2002/2003])).to eq [1999, 2000, 2002, 2003]
    end

    it 'multiple ranges with overlaps' do
      expect(range.parse_ranges(%w[1999/2005 2002/2003 2004/2004])).to eq [1999, 2000, 2001, 2002, 2003, 2004, 2005]
    end
  end

  describe '#gaps?' do
    it 'single year' do
      range << [1999]
      expect(range.gaps?).to be_falsey
    end

    it 'simple range' do
      range << [1999, 2000]
      expect(range.gaps?).to be_falsey
    end

    it 'multiple ranges with gaps' do
      range << [1999, 2000] << [2002, 2003]
      expect(range.gaps?).to be_truthy
    end
  end

  describe '#to_s' do
    it 'no years' do
      expect(described_class.new.to_s).to be_nil
    end

    it 'single year' do
      range << [1999]
      expect(range.to_s).to eq '1999'
    end

    it 'simple range' do
      range << [1999, 2000]
      expect(range.to_s).to eq '1999-2000'
    end

    it 'large range' do
      range << (1900..2000).to_a
      expect(range.to_s).to eq '1900-2000'
    end

    it 'multiple ranges' do
      range << [1999, 2000] << [2001, 2002, 2003] << [2004]
      expect(range.to_s).to eq '1999-2004'
    end

    it 'multiple ranges with single-year runs' do
      range << [1999] << [2002] << [2004]
      expect(range.to_s).to eq '1999, 2002, 2004'
    end

    it 'multiple ranges with single-year gaps' do
      range << [1999, 2000] << [2002]
      expect(range.to_s).to eq '1999-2000, 2002'
    end

    it 'multiple ranges with multi-year gaps and short run' do
      range << [1999] << [2002]
      expect(range.to_s).to eq '1999, 2002'
    end

    it 'multiple ranges with multi-year gaps and long run' do
      range << [1999, 2000] << [2002, 2003]
      expect(range.to_s).to eq '1999-2000, 2002-2003'
    end
  end
end
