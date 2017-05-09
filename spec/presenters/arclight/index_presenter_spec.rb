# frozen_string_literal: true

require 'spec_helper'

describe Arclight::IndexPresenter, type: :presenter do
  subject { presenter }

  let(:view_context) { ActionView::Base.new }

  let(:config) { Blacklight::Configuration.new }

  let(:presenter) { described_class.new(document, view_context, config) }

  let(:document) do
    SolrDocument.new(id: 1,
                     'title_ssm' => ['My Title'],
                     'unitdate_ssm' => ['1900-2000'])
  end

  before do
    expect(view_context).to receive_messages(
      controller: instance_double('Controller', params: {}, session: {}),
      default_document_index_view_type: 'index'
    )
    config.index.title_field = :title_ssm
  end

  describe '#label' do
    context 'with a title that ends in a comma' do
      it 'joins the title and date with a space' do
        expect(presenter.label('The Title,')).to eq 'The Title, 1900-2000'
      end
      context 'without a date' do
        let(:document) do
          SolrDocument.new(id: 1, 'title_ssm' => ['My Title,'])
        end

        it 'strips the trailing comma' do
          expect(presenter.label('The Title,')).to eq 'The Title'
        end
      end
    end

    context 'when a title that does not end in a comma' do
      it 'joins the title and date with a comma+space' do
        expect(presenter.label('The Title')).to eq 'The Title, 1900-2000'
      end
    end

    context 'when a title is missing' do
      it 'uses only the date' do
        expect(presenter.label('   ')).to eq '1900-2000'
        expect(presenter.label(nil)).to eq '1900-2000'
      end
    end
  end
end
