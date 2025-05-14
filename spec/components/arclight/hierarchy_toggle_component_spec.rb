# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::HierarchyToggleComponent, type: :component do
  let(:document) do
    instance_double(SolrDocument, id: 'abc123', children?: has_children)
  end

  let(:rendered) do
    render_inline(described_class.new(document: document, expanded: expanded))
  end

  context 'when the document has children' do
    let(:has_children) { true }

    context 'when expanded is true' do
      let(:expanded) { true }

      it 'does not include the .collapsed class' do
        expect(rendered.to_html).to include('class="al-toggle-view-children"')
        expect(rendered.to_html).not_to include('collapsed')
      end

      it 'renders the link with aria-expanded=true' do
        expect(rendered.to_html).to include('aria-expanded="true"')
      end
    end

    context 'when expanded is false' do
      let(:expanded) { false }

      it 'includes the .collapsed class' do
        expect(rendered.to_html).to include('class="al-toggle-view-children collapsed"')
      end

      it 'renders the link with aria-expanded=false' do
        expect(rendered.to_html).to include('aria-expanded="false"')
      end
    end
  end

  context 'when the document has no children' do
    let(:has_children) { false }
    let(:expanded) { false }

    it 'does not render the component' do
      expect(rendered.to_html).to be_empty
    end
  end
end
