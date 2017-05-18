# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::Viewer do
  subject(:viewer) { described_class.new(document) }

  let(:document) do
    SolrDocument.new(
      digital_objects_ssm: [{ href: 'http://example.com' }.to_json]
    )
  end

  let(:test_viewer_class) do
    Class.new do
      def initialize(*); end

      def to_partial_path
        'arclight/viewer/_does_not_exist'
      end
    end
  end

  describe '#render' do
    it 'renders the appropriate partial' do
      content = Capybara.string(viewer.render)
      expect(content).to have_css('.al-oembed-viewer', count: 1)
    end
  end

  it 'allows the viewer class to be configured' do
    expect(Arclight::Engine.config).to receive_messages(viewer_class: test_viewer_class)
    expect do # Our test viewer class does not have a real partial, so MissingTemplate is raised
      viewer.render
    end.to raise_error(ActionView::MissingTemplate, %r{Missing template arclight/viewer/_does_not_exist})
  end
end
