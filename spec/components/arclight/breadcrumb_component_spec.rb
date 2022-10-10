# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::BreadcrumbComponent, type: :component do
  let(:document) do
    SolrDocument.new(
      parent_ssim: %w[def ghi],
      parent_unittitles_ssm: %w[DEF GHI],
      ead_ssi: 'abc123',
      repository_ssm: 'my repository'
    )
  end

  let(:render) do
    component.render_in(controller.view_context)
  end

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:attr) { {} }

  let(:component) { described_class.new(document: document, **attr) }

  context 'with a count' do
    let(:attr) { { count: 2 } }

    it 'renders only that many breadcrumb links' do
      expect(rendered).to have_selector 'span', text: 'my repository'
      expect(rendered).to have_link 'DEF', href: '/catalog/abc123def'
      expect(rendered).not_to have_link 'GHI', href: '/catalog/abc123ghi'
    end

    it 'renders an ellipsis if there are more links than the count' do
      expect(render).to end_with '&hellip;'
    end
  end

  context 'with an offset' do
    let(:attr) { { offset: 2 } }

    it 'skips some breadcrumb links' do
      expect(rendered).not_to have_selector 'span', text: 'my repository'
      expect(rendered).not_to have_link 'DEF', href: '/catalog/abc123def'
      expect(rendered).to have_link 'GHI', href: '/catalog/abc123ghi'
    end
  end

  it 'renders breadcrumb links' do
    expect(rendered).to have_selector 'span', text: 'my repository'
    expect(rendered).to have_link 'DEF', href: '/catalog/abc123def'
    expect(rendered).to have_link 'GHI', href: '/catalog/abc123ghi'
  end
end
