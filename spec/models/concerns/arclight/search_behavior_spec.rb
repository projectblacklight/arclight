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

  describe '#add_facetting_to_solr' do
    context 'when in collection_context view' do
      let(:user_params) { { view: 'collection_context' } }

      it 'does not modify params' do
        expect(search_builder_instance.add_facetting_to_solr(solr_params)).to eq({})
      end
    end

    context 'in index view' do
      let(:user_params) { { view: 'index' } }

      it 'calls super (from Blacklight)' do
        expect do
          search_builder_instance.add_facetting_to_solr(solr_params)
        end.to raise_error(NoMethodError).with_message(/super/)
      end
    end
  end

  describe '#add_hierarchy_max_rows' do
    context 'when in collection_context view' do
      let(:user_params) { { view: 'collection_context' } }

      it 'adds pseudo unlimited rows to query' do
        expect(search_builder_instance.add_hierarchy_max_rows(solr_params)).to include(rows: 999_999_999)
      end
    end

    context 'when not in collection_context view' do
      it 'does not affect rows param' do
        expect(search_builder_instance.add_hierarchy_max_rows(solr_params)).to eq({})
      end
    end
  end

  describe '#add_hierarchy_sort' do
    context 'when in collection_context view' do
      let(:user_params) { { view: 'collection_context' } }

      it 'adds component-order sort to query' do
        expect(search_builder_instance.add_hierarchy_sort(solr_params)).to include(sort: 'sort_ii asc')
      end
    end

    context 'when not in collection_context view' do
      it 'does not affect sort param' do
        expect(search_builder_instance.add_hierarchy_sort(solr_params)).to eq({})
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
        expect(search_builder_instance.add_grouping(solr_params)).to include(
          group: true,
          'group.field': 'collection_ssi',
          'group.ngroups': true,
          'group.limit': 3,
          'parent.fl': '*',
          'parent.q': '{!term f=collection_sim v=$row.collection_ssi}',
          'parent.fq': '{!term f=level_sim v="Collection"}',
          'parent.defType': 'lucene'
        )
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
