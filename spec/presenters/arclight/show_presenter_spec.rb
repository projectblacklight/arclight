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
    it 'handles missing date' do
      allow(document).to receive(:fetch).with('unitdate_ssm', []).and_return(nil)
      expect(presenter.heading).to eq 'My Title'
    end
  end
end
