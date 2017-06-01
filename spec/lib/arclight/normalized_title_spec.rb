# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::NormalizedTitle do
  subject(:normalized_title) { described_class.new(title, date).to_s }

  let(:title) { 'My Title' }
  let(:date) { '1990-2000' }
  let(:id) { '1234' }

  context 'under normal conditions' do
    it 'joins the title and date' do
      expect(normalized_title).to eq 'My Title, 1990-2000'
    end
  end

  context 'with special case titles' do
    context 'punctuated titles' do
      let(:title) { 'My, Title' }

      it 'joins the title as-is and date' do
        expect(normalized_title).to eq 'My, Title, 1990-2000'
      end
    end

    context 'buggy title (comma at end)' do
      let(:title) { 'My Title,' }

      it 'cleans up the title and joins with the date' do
        expect(normalized_title).to eq 'My Title, 1990-2000'
      end
    end

    context 'buggy title (quoted comma at end)' do
      let(:title) { '"My Title,"' }

      it 'is buggy but we allow it' do
        expect(normalized_title).to eq '"My Title,", 1990-2000'
      end
    end

    context 'spacey title' do
      let(:title) { '   My Title   ' }

      it 'cleans up the title and joins with the date' do
        expect(normalized_title).to eq 'My Title, 1990-2000'
      end
    end

    context 'blank title' do
      let(:title) { '  ' }

      it 'uses only the date' do
        expect(normalized_title).to eq date
      end
    end

    context 'missing title' do
      let(:title) { nil }

      it 'uses only the date' do
        expect(normalized_title).to eq date
      end
    end
  end

  context 'with special case dates' do
    context 'spacey date' do
      let(:date) { '  1990-2000  ' }

      it 'joins the title and date' do
        expect(normalized_title).to eq 'My Title, 1990-2000'
      end
    end

    context 'just n.d.' do
      let(:date) { 'n.d.' }

      it 'joins the title and date as-is' do
        expect(normalized_title).to eq 'My Title, n.d.'
      end
    end

    context 'extra n.d.' do
      let(:date) { '1990-2000, bulk n.d.' }

      it 'joins the title and date as-is' do
        expect(normalized_title).to eq 'My Title, 1990-2000, bulk n.d.'
      end
    end

    context 'extra year/range' do
      let(:date) { '1956-1994, bulk 1968-1993' }

      it 'joins the title and date as-is' do
        expect(normalized_title).to eq 'My Title, 1956-1994, bulk 1968-1993'
      end
    end

    context 'blank date' do
      let(:date) { '   ' }

      it 'uses only the title' do
        expect(normalized_title).to eq title
      end
    end

    context 'missing date' do
      let(:date) { nil }

      it 'uses only the title' do
        expect(normalized_title).to eq title
      end
    end
  end

  context 'no title or date' do
    let(:title) { nil }
    let(:date) { nil }

    it do
      expect { normalized_title }.to raise_error(
        Arclight::Exceptions::TitleNotFound,
        '<unittitle/> or <unitdate/> must be present for all documents and components'
      )
    end
  end
end
