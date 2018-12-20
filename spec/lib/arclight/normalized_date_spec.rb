# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::NormalizedDate do
  subject(:normalized_date) { described_class.new(date_inclusive, date_bulk, date_other).to_s }

  let(:date_inclusive) { ['1990-2000'] }
  let(:date_bulk) { '1999-2005' }
  let(:date_other) { nil }

  context 'under normal conditions' do
    it 'joins dates' do
      expect(normalized_date).to eq '1990-2000, bulk 1999-2005'
    end

    context 'multiple normalized dates' do
      let(:date_inclusive) { %w[1990 1992] }

      it 'are joined w/ a comma' do
        expect(normalized_date).to eq '1990, 1992, bulk 1999-2005'
      end
    end
  end

  context 'with special case dates' do
    # NOTE: This test is the only place where the code that exercises this is routable
    # This has to be a multidimensional array, and the resulting XML nodes sent in are always flat
    context 'multiples' do
      let(:date_inclusive) { [%w[1990-2000 2001-2002 2004]] }
      let(:date_bulk) { '1990-2004' }

      it 'uses compressed joined years' do
        expect(normalized_date).to eq '1990-2002, 2004, bulk 1990-2004'
      end
    end

    context 'undated' do
      let(:date_bulk) { 'n.d.' }

      it 'do not normalized term "undated"' do
        expect(normalized_date).to eq '1990-2000, bulk n.d.'
      end
    end

    context 'circa' do
      let(:date_bulk) { 'c.1995' }

      it 'do not normalized term "circa"' do
        expect(normalized_date).to eq '1990-2000, bulk c.1995'
      end
    end

    context 'no bulk' do
      let(:date_bulk) { nil }

      it 'uses inclusive date only' do
        expect(normalized_date).to eq '1990-2000'
      end
    end

    context 'no inclusive or bulk but other' do
      let(:date_inclusive) { nil }
      let(:date_bulk) { nil }
      let(:date_other) { 'n.d.' }

      it 'uses other' do
        expect(normalized_date).to eq 'n.d.'
      end
    end

    context 'no inclusive but bulk' do
      let(:date_inclusive) { nil }

      it 'does not know what to do' do
        expect(normalized_date).to be_nil
      end
    end

    context 'no information' do
      let(:date_inclusive) { nil }
      let(:date_bulk) { nil }

      it 'does not know what to do' do
        expect(normalized_date).to be_nil
      end
    end
  end
end
