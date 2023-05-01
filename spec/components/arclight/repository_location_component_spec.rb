# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::RepositoryLocationComponent, type: :component do
  let(:field) do
    instance_double(Blacklight::FieldPresenter, key: 'blah', document: nil, label: 'blah', values: [Arclight::Repository.all.first], render_field?: true)
  end
  let(:render) do
    component.render_in(vc_test_controller.view_context)
  end

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:component) { described_class.new(field: field) }

  it 'renders the repository location information' do
    expect(rendered).to have_css('.al-in-person-repository-name', text: 'My Repository')
    expect(rendered).to have_css('address .al-repository-street-address-building', text: 'My Building')
  end
end
