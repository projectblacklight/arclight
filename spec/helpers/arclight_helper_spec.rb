# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ArclightHelper, type: :helper do
  describe '#collection_active?' do
    context 'with active collection search' do
      let(:search_state) do
        instance_double(
          'Blacklight::SearchState',
          params_for_search: { 'f' => { 'level_sim' => ['Collection'] } }
        )
      end

      before do
        allow(helper).to receive(:search_state).and_return(search_state)
      end
      it do
        expect(helper.collection_active?).to eq true
      end
    end
    context 'without active collection search' do
      let(:search_state) do
        instance_double(
          'Blacklight::SearchState',
          params_for_search: {}
        )
      end

      before do
        allow(helper).to receive(:search_state).and_return(search_state)
      end
      it do
        expect(helper.collection_active?).to eq false
      end
    end
  end
  describe '#grouped?' do
    context 'when group is active' do
      let(:search_state) do
        instance_double(
          'Blacklight::SearchState',
          params_for_search: { 'group' => 'true' }
        )
      end

      before do
        allow(helper).to receive(:search_state).and_return(search_state)
      end
      it do
        expect(helper.grouped?).to be_truthy
      end
    end
    context 'when not grouped' do
      let(:search_state) do
        instance_double(
          'Blacklight::SearchState',
          params_for_search: { 'hello' => 'true' }
        )
      end

      before do
        allow(helper).to receive(:search_state).and_return(search_state)
      end
      it do
        expect(helper.grouped?).to be_falsey
      end
    end
  end
  describe '#search_with_group' do
    let(:search_state) do
      instance_double(
        'Blacklight::SearchState',
        params_for_search: { 'q' => 'hello', 'page' => '2' }
      )
    end

    before do
      allow(helper).to receive(:search_state).and_return(search_state)
    end
    it do
      expect(helper.search_with_group).to eq(
        'q' => 'hello',
        'group' => 'true'
      )
    end
  end
  describe '#search_without_group' do
    let(:search_state) do
      instance_double(
        'Blacklight::SearchState',
        params_for_search: { 'q' => 'hello', 'group' => 'true', 'page' => '2' }
      )
    end

    before do
      allow(helper).to receive(:search_state).and_return(search_state)
    end
    it do
      expect(helper.search_without_group).to eq(
        'q' => 'hello'
      )
    end
  end
  describe '#on_repositories_index?' do
    before { allow(helper).to receive(:action_name).twice.and_return('index') }

    context 'with repositories index' do
      it do
        allow(helper).to receive(:controller_name).twice.and_return('repositories')
        expect(helper.on_repositories_index?).to eq true
        expect(helper.repositories_active_class).to eq 'active'
      end
    end
    context 'without repositories index' do
      it do
        allow(helper).to receive(:controller_name).twice.and_return('NOT repositories')
        expect(helper.on_repositories_index?).to eq false
        expect(helper.repositories_active_class).to eq nil
      end
    end
  end
  describe '#on_repositories_show?' do
    before { allow(helper).to receive(:action_name).twice.and_return('show') }

    context 'with repositories show' do
      it do
        allow(helper).to receive(:controller_name).twice.and_return('repositories')
        expect(helper.on_repositories_show?).to eq true
        expect(helper.repositories_active_class).to eq nil
      end
    end
    context 'without repositories show' do
      it do
        allow(helper).to receive(:controller_name).twice.and_return('NOT repositories')
        expect(helper.on_repositories_show?).to eq false
        expect(helper.repositories_active_class).to eq nil
      end
    end
  end
  describe '#collection_count' do
    context 'when there are items' do
      it 'returns the item count from the Blacklight::Solr::Response' do
        assign(:response, instance_double('Response', response: { 'numFound' => 2 }))

        expect(helper.collection_count).to eq 2
      end
    end

    context 'when there are no items' do
      it do
        assign(:response, instance_double('Response', response: {}))
        expect(helper.collection_count).to be_nil
      end
    end
  end

  describe '#fields_have_content?' do
    before do
      expect(helper).to receive_messages(
        blacklight_config: CatalogController.blacklight_config,
        blacklight_configuration_context: Blacklight::Configuration::Context.new(helper)
      )
    end

    context 'when the configured fields have content' do
      let(:document) { SolrDocument.new('acqinfo_ssim': ['Data']) }

      it 'is true' do
        expect(helper.fields_have_content?(document, :background_field)).to eq true
      end
    end

    context 'when the configured fields have no content' do
      let(:document) { SolrDocument.new }

      it 'is true' do
        expect(helper.fields_have_content?(document, :background_field)).to eq false
      end
    end
  end

  describe '#parents_to_links' do
    let(:document) do
      SolrDocument.new(
        parent_ssim: %w[def ghi],
        parent_unittitles_ssm: %w[DEF GHI],
        ead_ssi: 'abc123',
        repository_ssm: 'my repository'
      )
    end

    it 'converts "parents" from SolrDocument to links' do
      expect(helper.parents_to_links(document)).to include 'my repository'
      expect(helper.parents_to_links(document)).to include 'DEF'
      expect(helper.parents_to_links(document)).to include solr_document_path('abc123def')
      expect(helper.parents_to_links(document)).to include 'GHI'
      expect(helper.parents_to_links(document)).to include solr_document_path('abc123ghi')
    end

    it 'properly delimited' do
      expect(helper.parents_to_links(document)).to include '<span aria-hidden="true"> » </span>'
      expect(helper.parents_to_links(SolrDocument.new)).not_to include '»'
    end
  end

  describe '#component_parents_to_links' do
    let(:document) do
      SolrDocument.new(
        parent_ssim: %w[def ghi jkl],
        parent_unittitles_ssm: %w[DEF GHI JKL],
        ead_ssi: 'abc123'
      )
    end

    it 'converts component "parents" from SolrDocument to links' do
      expect(helper.component_parents_to_links(document)).not_to include 'DEF'
      expect(helper.component_parents_to_links(document)).not_to include solr_document_path('abc123def')
      expect(helper.component_parents_to_links(document)).to include 'GHI'
      expect(helper.component_parents_to_links(document)).to include solr_document_path('abc123ghi')
    end

    it 'properly delimited' do
      expect(helper.component_parents_to_links(document)).to include '<span aria-hidden="true"> » </span>'
    end
  end

  describe '#regular_compact_breadcrumbs' do
    context 'when the component only has one parent (meaning it is a top level parent)' do
      let(:document) do
        SolrDocument.new(
          parent_ssim: %w[def],
          parent_unittitles_ssm: %w[DEF],
          ead_ssi: 'abc123',
          repository_ssm: 'my repository'
        )
      end

      it 'links to repository and top level component and does not include an ellipsis' do
        expect(helper.regular_compact_breadcrumbs(document)).to include 'my repository'
        expect(helper.regular_compact_breadcrumbs(document)).to include 'DEF'
        expect(helper.regular_compact_breadcrumbs(document)).to include solr_document_path('abc123def')
        expect(helper.regular_compact_breadcrumbs(document)).to include '<span aria-hidden="true"> » </span>'
        expect(helper.regular_compact_breadcrumbs(document)).not_to include '&hellip;'
      end
    end

    context 'when the component is a child of a top level component' do
      let(:document) do
        SolrDocument.new(
          parent_ssim: %w[def ghi],
          parent_unittitles_ssm: %w[DEF GHI],
          ead_ssi: 'abc123',
          repository_ssm: 'my repository'
        )
      end

      it 'links to the top level component and does include an ellipsis' do
        expect(helper.regular_compact_breadcrumbs(document)).to include 'DEF'
        expect(helper.regular_compact_breadcrumbs(document)).to include solr_document_path('abc123def')
        expect(helper.regular_compact_breadcrumbs(document)).to include '<span aria-hidden="true"> » </span>'
        expect(helper.regular_compact_breadcrumbs(document)).to include '&hellip;'
      end
    end
  end

  describe '#component_top_level_parent_to_links' do
    context 'when the component only has one parent (meaning it is a top level parent)' do
      let(:document) do
        SolrDocument.new(parent_ssim: %w[def], parent_unittitles_ssm: %w[DEF], ead_ssi: 'abc123')
      end

      it { expect(helper.component_top_level_parent_to_links(document)).to be_nil }
    end

    context 'when the component is a child of a top level component' do
      let(:document) do
        SolrDocument.new(
          parent_ssim: %w[def ghi],
          parent_unittitles_ssm: %w[DEF GHI],
          ead_ssi: 'abc123'
        )
      end

      it 'links to the top level component and does not include an ellipsis' do
        expect(helper.component_top_level_parent_to_links(document)).to include 'GHI'
        expect(helper.component_top_level_parent_to_links(document)).to include solr_document_path('abc123ghi')
        expect(helper.component_top_level_parent_to_links(document)).not_to include '»'
        expect(helper.component_top_level_parent_to_links(document)).not_to include '&hellip;'
      end
    end

    context 'when the component is several levels deep' do
      let(:document) do
        SolrDocument.new(
          parent_ssim: %w[def ghi jkl],
          parent_unittitles_ssm: %w[DEF GHI JKL],
          ead_ssi: 'abc123'
        )
      end

      it 'links to the top level component and joins it with an ellipsis' do
        expect(helper.component_top_level_parent_to_links(document)).to include 'GHI'
        expect(helper.component_top_level_parent_to_links(document)).to include solr_document_path('abc123ghi')
        expect(helper.component_top_level_parent_to_links(document)).to include '<span aria-hidden="true"> » </span>'
        expect(helper.component_top_level_parent_to_links(document)).to include '&hellip;'
      end
    end
  end

  describe '#search_results_header_text' do
    let(:text) { helper.search_results_header_text }

    context 'when searching within a repository' do
      before do
        expect(helper).to receive_messages(
          repository_faceted_on: instance_double('Arclight::Repostory', name: 'Repository Name')
        )
      end

      it { expect(text).to eq 'Collections : [Repository Name]' }
    end

    context 'when searching all collections' do
      before do
        expect(helper).to receive_messages(
          search_state: instance_double(
            'Blacklight::SearchState', params_for_search: { 'f' => { 'level_sim' => ['Collection'] } }
          ),
          facet_field_in_params?: false
        )
      end

      it { expect(text).to eq 'Collections' }
    end

    context 'all other non-special search behavior' do
      it { expect(text).to eq 'Search' }
    end
  end

  describe 'document_or_parent_icon' do
    let(:document) { SolrDocument.new('level_ssm': ['collection']) }

    it 'properly assigns the icon' do
      expect(helper.document_or_parent_icon(document)).to eq 'collection'
    end

    context 'there is no level_ssm' do
      let(:document) { SolrDocument.new }

      it 'gives the default icon' do
        expect(helper.document_or_parent_icon(document)).to eq 'container'
      end
    end
  end

  describe 'custom field accessors' do
    let(:accessors) { Arclight::Engine.config.catalog_controller_field_accessors }
    let(:field) { :yolo }

    describe '#document_config_fields' do
      it do
        accessors.each do |accessor|
          expect(helper).to respond_to :"document_#{accessor}s"
        end
      end
    end
    describe '#render_document_config_field_label' do
      it do
        accessors.each do |accessor|
          expect(helper).to respond_to :"render_document_#{accessor}_label"
        end
      end
    end
    describe '#document_config_field_label' do
      it do
        accessors.each do |accessor|
          expect(helper).to respond_to :"document_#{accessor}_label"
        end
      end
    end
    describe '#should_render_config_field?' do
      it do
        accessors.each do |accessor|
          expect(helper).to respond_to :"should_render_#{accessor}?"
        end
      end
    end
    describe '#generic_document_fields' do
      it 'send along the method call' do
        expect(helper).to receive_messages(document_yolos: nil)
        helper.generic_document_fields(field)
      end
    end
    describe '#generic_should_render_field?' do
      it 'send along the method call' do
        expect(helper).to receive_messages(should_render_yolo?: nil)
        helper.generic_should_render_field?(field, 0, 1)
      end
    end
    describe '#generic_render_document_field_label?' do
      it 'send along the method call' do
        expect(helper).to receive_messages(render_document_yolo_label: nil)
        helper.generic_render_document_field_label(field, 0, field: 1)
      end
    end
  end
  describe '#hierarchy_component_context?' do
    it 'requires a parameter to enable' do
      allow(helper).to receive(:params).and_return(hierarchy_context: 'component')
      expect(helper.hierarchy_component_context?).to be_truthy
    end

    it 'omission is disabled' do
      allow(helper).to receive(:params).and_return({})
      expect(helper.hierarchy_component_context?).to be_falsey
    end
  end
end
