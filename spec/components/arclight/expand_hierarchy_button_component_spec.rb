# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::ExpandHierarchyButtonComponent, type: :component do
  subject(:component) { described_class.new(path: '/some/path') }

  before do
    render_inline(component)
  end

  it 'renders the button' do
    expect(page).to have_text('Expand')
    expect(page).to have_css('.btn.btn-secondary.btn-sm')
  end

  context 'with a custom class' do
    subject(:component) { described_class.new(path: '/path/to_file', classes: 'btn btn-primary') }

    it 'renders the button with the custom classes' do
      expect(page).to have_text('Expand')
      expect(page).to have_css('.btn.btn-primary')
    end
  end
end
