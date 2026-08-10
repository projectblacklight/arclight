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

  describe '#add_hierarchy_behavior' do
    let(:solr_params) { {} }

    context 'when the action is hierarchy' do
      before do
        allow(context).to receive(:action_name).and_return('hierarchy')
      end

      it 'restricts fl to stored fields to avoid the per-component collection subquery' do
        search_builder_instance.add_hierarchy_behavior(solr_params)
        expect(solr_params[:fl]).to eq('*')
      end
    end

    context 'when the action is not hierarchy' do
      before do
        allow(context).to receive(:action_name).and_return('index')
      end

      it 'does not override fl' do
        search_builder_instance.add_hierarchy_behavior(solr_params)
        expect(solr_params).not_to have_key(:fl)
      end
    end
  end

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
