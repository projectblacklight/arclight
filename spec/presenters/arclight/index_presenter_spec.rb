# frozen_string_literal: true

require 'spec_helper'

describe Arclight::IndexPresenter, type: :presenter do
  subject { presenter }

  let(:view_context) { ActionView::Base.new }

  let(:config) { Blacklight::Configuration.new }

  let(:presenter) { described_class.new(document, view_context, config) }

  let(:document) do
    SolrDocument.new(id: 1,
                     'normalized_title_ssm' => 'My Title, 1900-2000')
  end

  before do
    expect(view_context).to receive_messages(
      controller: instance_double('Controller', params: {}, session: {}),
      default_document_index_view_type: 'index'
    )
    config.index.title_field = :normalized_title_ssm
  end

  describe '#label' do
    it 'uses normalized title' do
      expect(presenter.label).to eq 'My Title, 1900-2000'
    end
  end
end
