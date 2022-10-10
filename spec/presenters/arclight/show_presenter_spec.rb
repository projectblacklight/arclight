# frozen_string_literal: true

require 'spec_helper'

describe Arclight::ShowPresenter, type: :presenter do
  subject { presenter }

  let(:view_context) { ActionView::Base.new(nil, {}, nil) }
  let(:config) { Blacklight::Configuration.new }

  let(:presenter) { described_class.new(document, view_context, config) }

  let(:document) do
    SolrDocument.new(id: 1,
                     'normalized_title_ssm' => ['My Title, 1900-2000'])
  end

  before do
    config.show.title_field = :normalized_title_ssm
  end

  describe '#heading' do
    it 'uses normalized title' do
      expect(presenter.heading).to eq 'My Title, 1900-2000'
    end
  end

  describe '#with_field_group' do
    it 'is nil when none is set' do
      expect(presenter.send(:field_group)).to be_nil
    end

    it 'sets the field group based on the given field accessor (and returns the presenter)' do
      returned_presenter = presenter.with_field_group('a_group')
      expect(returned_presenter).to be_a Arclight::ShowPresenter
      expect(returned_presenter.send(:field_group)).to eq 'a_group'
    end
  end

  describe '#field_config' do
    it 'returns a field configuration (NullField in this context)' do
      if Blacklight::VERSION > '8'
        expect(presenter.send(:field_config, 'some_field')).to be_a Blacklight::Configuration::NullDisplayField
      else
        expect(presenter.send(:field_config, 'some_field')).to be_a Blacklight::Configuration::NullField
      end
    end
  end
end
