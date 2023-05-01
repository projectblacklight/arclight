# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::SearchBarComponent, type: :component do
  let(:render) do
    component.render_in(view_context)
  end
  let(:view_context) { vc_test_controller.view_context }

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:params) { {} }
  let(:component) { described_class.new(url: '/', params: params) }

  describe 'within collection dropdown' do
    context 'when in a collection context on the search results page' do
      let(:params) { { f: { collection: ['some collection'] } } }

      it 'renders a name attribute on the select (so it will be sent through the form)' do
        expect(rendered).to have_css('select[name="f[collection][]"]')
      end

      it 'has the "this collection" option selected' do
        expect(rendered).to have_css('select option[selected]', text: 'this collection')
      end
    end

    context 'when in a collection context, e.g. on show page for a collection' do
      let(:document) { SolrDocument.new(id: 'abc123', collection: { docs: [{ normalized_title_ssm: ['some collection'] }] }) }

      before do
        allow(view_context).to receive(:current_context_document).and_return(document)
      end

      it 'renders a name attribute on the select (so it will be sent through the form)' do
        expect(rendered).to have_css('select[name="f[collection][]"]')
      end

      it 'has the "this collection" option selected' do
        expect(rendered).to have_css('select option[selected]', text: 'this collection')
      end
    end

    context 'when not in a collection context' do
      it 'does not render a name attribute on the select (because it does not need to be sent through the form)' do
        expect(rendered).not_to have_select 'name'
      end

      it 'has the "this collection" option disabled' do
        expect(rendered).to have_css('select option[disabled]', text: 'this collection')
      end
    end
  end
end
