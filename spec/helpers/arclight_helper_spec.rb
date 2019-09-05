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
        params_for_search: { 'q' => 'hello' }
      )
    end

    before do
      allow(helper).to receive(:search_state).and_return(search_state)
    end
    it do
      expect(helper.search_with_group).to eq '/catalog?group=true&q=hello'
    end
  end
  describe '#search_without_group' do
    let(:search_state) do
      instance_double(
        'Blacklight::SearchState',
        params_for_search: { 'q' => 'hello', 'group' => 'true' }
      )
    end

    before do
      allow(helper).to receive(:search_state).and_return(search_state)
    end
    it do
      expect(helper.search_without_group).to eq '/catalog?q=hello'
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
      let(:document) { SolrDocument.new('acqinfo_ssm': ['Data']) }

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
        parent_ssm: %w[def ghi],
        parent_unittitles_ssm: %w[DEF GHI],
        ead_ssi: 'abc123'
      )
    end

    it 'converts "parents" from SolrDocument to links' do
      expect(helper.parents_to_links(document)).to include 'DEF'
      expect(helper.parents_to_links(document)).to include solr_document_path('abc123def')
      expect(helper.parents_to_links(document)).to include 'GHI'
      expect(helper.parents_to_links(document)).to include solr_document_path('abc123ghi')
    end
    it 'properly delimited' do
      expect(helper.parents_to_links(document)).to include '»'
      expect(helper.parents_to_links(SolrDocument.new)).not_to include '»'
    end
  end

  describe 'document_header_icon' do
    let(:document) { SolrDocument.new('level_ssm': ['collection']) }

    it 'properly assigns the icon' do
      expect(helper.document_header_icon(document)).to eq 'search'
    end

    context 'there is no level_ssm' do
      let(:document) { SolrDocument.new }

      it 'gives the default icon' do
        expect(helper.document_header_icon(document)).to eq 'compact'
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
  context '#hierarchy_component_context?' do
    it 'requires a parameter to enable' do
      allow(helper).to receive(:params).and_return(hierarchy_context: 'component')
      expect(helper.hierarchy_component_context?).to be_truthy
    end
    it 'omission is disabled' do
      allow(helper).to receive(:params).and_return({})
      expect(helper.hierarchy_component_context?).to be_falsey
    end
  end
  context '#collection_downloads' do
    let(:document) { SolrDocument.new('unitid_ssm' => 'MS C 271') }
    let(:config_file) { File.join('spec', 'fixtures', 'config', 'downloads.yml') }
    let(:config_data) { YAML.safe_load(File.read(config_file)) }

    it 'no download metadata' do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect(helper.collection_downloads(document)).to eq({})
    end
    it 'handles no downloads' do
      expect(helper.collection_downloads(document, {})).to eq({})
    end
    it 'handles PDF downloads' do
      expect(helper.collection_downloads(document, config_data)[:pdf]).to include(
        href: 'http://example.com/MS+C+271.pdf',
        size: '1.23MB'
      )
    end
    it 'handles EAD downloads' do
      expect(helper.collection_downloads(document, config_data)[:ead]).to include(
        href: 'http://example.com/MS+C+271.xml',
        size: '121 KB'
      )
    end
  end
end
