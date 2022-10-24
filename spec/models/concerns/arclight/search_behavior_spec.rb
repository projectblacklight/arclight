# frozen_string_literal: true

require 'spec_helper'

describe Arclight::SearchBehavior do
  subject(:search_builder_instance) { search_builder.with(user_params) }

  let(:user_params) { {} }
  let(:solr_params) { {} }
  let(:context) { CatalogController.new }
  let(:search_builder_class) do
    Class.new(Blacklight::SearchBuilder).tap do |klass|
      include Blacklight::Solr::SearchBuilderBehavior
      klass.include(described_class)
    end
  end
  let(:search_builder) { search_builder_class.new(context) }

  describe '#add_highlighting' do
    it 'enables highlighting' do
      expect(search_builder_instance.add_highlighting(solr_params)).to include('hl' => true)
    end
  end

  describe '#add_grouping' do
    context 'when group is selected' do
      let(:user_params) { { group: 'true' } }

      it 'adds grouping params' do
        expect(search_builder_instance.add_grouping(solr_params)).to include(Arclight::Engine.config.catalog_controller_group_query_params)
      end
    end

    context 'when group is not selected' do
      it 'enables highlighting' do
        expect(search_builder_instance.add_grouping(solr_params)).not_to include(
          group: true
        )
      end
    end
  end
end
