# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::BreadcrumbComponent, type: :component do
  let(:document) do
    SolrDocument.new(
      parent_ids_ssim: %w[abc123 abc123_def abc123_ghi],
      parent_unittitles_ssm: %w[ABC123 DEF GHI],
      ead_ssi: 'abc123',
      repository_ssm: 'my repository'
    )
  end

  let(:render) do
    component.render_in(vc_test_controller.view_context)
  end

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:attr) { {} }

  let(:component) { described_class.new(document: document, **attr) }

  context 'with a count' do
    let(:attr) { { count: 2 } }

    it 'renders only that many breadcrumb links' do
      expect(rendered).to have_selector 'li', text: 'my repository'
      expect(rendered).to have_link 'ABC123', href: '/catalog/abc123'
      expect(rendered).to have_no_link 'DEF', href: '/catalog/abc123_def'
      expect(rendered).to have_no_link 'GHI', href: '/catalog/abc123_ghi'
    end

    it 'renders an ellipsis if there are more links than the count' do
      expect(render).to end_with '>&hellip;</li></ol>'
    end
  end

  context 'with an offset' do
    let(:attr) { { offset: 2 } }

    it 'skips some breadcrumb links' do
      expect(rendered).to have_no_selector 'li', text: 'my repository'
      expect(rendered).to have_no_link 'ABC123', href: '/catalog/abc123'
      expect(rendered).to have_link 'DEF', href: '/catalog/abc123_def'
      expect(rendered).to have_link 'GHI', href: '/catalog/abc123_ghi'
    end
  end

  it 'renders breadcrumb links' do
    expect(rendered).to have_selector 'li', text: 'my repository'
    expect(rendered).to have_link 'DEF', href: '/catalog/abc123_def'
    expect(rendered).to have_link 'GHI', href: '/catalog/abc123_ghi'
  end
end
