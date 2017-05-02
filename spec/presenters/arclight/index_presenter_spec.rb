# frozen_string_literal: true

require 'spec_helper'

describe Arclight::IndexPresenter, type: :presenter do
  subject { presenter }

  let(:request_context) { instance_double('Context', document_index_view_type: 'index') }
  let(:config) { Blacklight::Configuration.new }

  let(:presenter) { described_class.new(document, request_context, config) }

  let(:document) do
    SolrDocument.new(id: 1,
                     'title_ssm' => ['My Title'],
                     'unitdate_ssm' => ['1900-2000'])
  end

  before do
    config.index.title_field = :title_ssm
  end

  describe '#label' do
    context 'with a title that ends in a comma' do
      it 'joins the title and date with a space' do
        expect(presenter.label('The Title,')).to eq 'The Title, 1900-2000'
      end
    end

    context 'when a title that does not end in a comma' do
      it 'joins the title and date with a comma+space' do
        expect(presenter.label('The Title')).to eq 'The Title, 1900-2000'
      end
    end
  end
end
