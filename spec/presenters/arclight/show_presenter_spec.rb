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

  describe '#fields_have_content?' do
    before do
      allow(view_context).to receive_messages(
        should_render_field?: true,
        document_background_fields: CatalogController.blacklight_config.background_fields
      )
    end

    context 'when the configured fields have content' do
      let(:document) { SolrDocument.new(acqinfo_ssim: ['Data']) }

      it 'is true' do
        expect(presenter.fields_have_content?(:background_field)).to be true
      end
    end

    context 'when the configured fields have no content' do
      let(:document) { SolrDocument.new }

      it 'is true' do
        expect(presenter.fields_have_content?(:background_field)).to be false
      end
    end
  end
end
