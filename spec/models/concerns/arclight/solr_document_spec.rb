# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::SolrDocument do
  let(:document) { SolrDocument.new }

  describe 'custom accessors' do
    it { expect(document).to respond_to(:parent_ids) }
    it { expect(document).to respond_to(:parent_labels) }
    it { expect(document).to respond_to(:eadid) }
  end
end
