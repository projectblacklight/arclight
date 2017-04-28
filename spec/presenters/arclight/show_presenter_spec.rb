# frozen_string_literal: true

require 'spec_helper'

describe Arclight::ShowPresenter, type: :presenter do
  subject { presenter }

  let(:request_context) { double }
  let(:config) { Blacklight::Configuration.new }

  let(:presenter) { described_class.new(document, request_context, config) }

  let(:document) do
    SolrDocument.new(id: 1,
                     'title_ssm' => ['My Title'],
                     'unitdate_ssm' => ['1900-2000'])
  end

  before do
    config.show.title_field = :title_ssm
  end

  describe '#heading' do
    it 'appends the date' do
      expect(presenter.heading).to eq 'My Title, 1900-2000'
    end

    context 'documents without dates' do
      let(:document) { SolrDocument.new(id: 1, 'title_ssm' => ['My Title']) }

      it 'only renders the title' do
        expect(presenter.heading).to eq 'My Title'
      end
    end

    context 'titles with commas' do
      let(:document) do
        SolrDocument.new(id: 1,
                         'title_ssm' => ['My Title,'],
                         'unitdate_ssm' => ['1900-2000'])
      end

      it 'does not duplicate commas' do
        expect(presenter.heading).to eq 'My Title, 1900-2000'
      end
    end
  end

  describe '#with_field_group' do
    it 'defaults to the show_field group when none is set' do
      expect(presenter.send(:field_group)).to eq 'show_field'
    end

    it 'sets the field group based on the given field accessor (and returns the presenter)' do
      returned_presenter = presenter.with_field_group('a_group')
      expect(returned_presenter).to be_a Arclight::ShowPresenter
      expect(returned_presenter.send(:field_group)).to eq 'a_group'
    end
  end

  describe '#field_config' do
    it 'returns a field configuration (NullField in this context)' do
      expect(presenter.send(:field_config, 'some_field')).to be_a Blacklight::Configuration::NullField
    end
  end
end
