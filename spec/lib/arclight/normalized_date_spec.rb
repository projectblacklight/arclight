# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::NormalizedDate do
  subject(:normalized_date) { described_class.new(unitdates, unitdate_labels).to_s }

  let(:unitdates) { ['1905', '1927-2000', '1982-1995'] }
  let(:unitdate_labels) { '', 'inclusive', 'bulk' }

  context 'under normal conditions' do
    it 'joins dates' do
      expect(normalized_date).to eq '1905, 1927-2000, bulk 1982-1995'
    end

    context 'multiple normalized dates' do
      let(:unitdates) { %w[1990 1992] }
      let(:unitdate_labels) { %w[inclusive inclusive] }

      it 'are joined w/ a comma' do
        expect(normalized_date).to eq '1990, 1992'
      end
    end
  end

  context 'with special case dates' do
    # NOTE: This test is the only place where the code that exercises this is routable
    # This has to be a multidimensional array, and the resulting XML nodes sent in are always flat
    context 'multiples' do
      let(:unitdates) { [%w[1990-2000 2001-2002 2004 1990-2004]] }
      let(:unitdate_labels) { [%w[inclusive inclusive INCLUSIVE bulk] }

      it 'uses compressed joined years' do
        expect(normalized_date).to eq '1990-2000, 2001-2002, 2004, bulk 1990-2004'
      end
    end

    context 'undated' do
      let(:unitdates) { ['1905', '1927-2000', 'n.d.'] }

      it 'do not normalized term "undated"' do
        expect(normalized_date).to eq '1905, 1927-2000, bulk n.d.'
      end
    end

    context 'circa' do
      let(:unitdates) { ['1990-2000', 'c.1995'] }
      let(:unitdate_labels) { ['', 'bulk'] }

      it 'do not normalized term "circa"' do
        expect(normalized_date).to eq '1990-2000, bulk c.1995'
      end
    end

    context 'no bulk' do
      let(:unitdate_labels) { ['', 'inclusive', ''] }

      it 'uses inclusive date only' do
        expect(normalized_date).to eq '1905, 1927-2000, 1982-1995'
      end
    end

    context 'no inclusive or bulk but other' do
      let(:unitdates) { %w[1963 1954] }
      let(:unitdate_labels) { ['', ''] }

      it 'uses other' do
        expect(normalized_date).to eq '1963, 1954'
      end
    end

    context 'no inclusive but bulk' do
      let(:unitdates) { %w[1963 1954-1990] }
      let(:unitdate_labels) { ['bulk', ''] }

      it 'does not know what to do' do
        expect(normalized_date).to eq 'bulk 1963, 1954-1990'
      end
    end

    context 'no information' do
      let(:unitdates) { nil }
      let(:unitdate_labels) { nil }

      it 'does not know what to do' do
        expect(normalized_date).to be_nil
      end
    end
  end
end
