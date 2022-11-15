# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arclight::CollectionSidebarComponent, type: :component do
  subject(:component) do
    described_class.new(document: document,
                        partials: CatalogController.blacklight_config.show.metadata_partials,
                        collection_presenter: collection_presenter)
  end

  before do
    render_inline(component)
  end

  let(:document) { instance_double(SolrDocument, normalized_eadid: 'foo') }
  let(:collection_presenter) { instance_double(Arclight::ShowPresenter, with_field_group: group_presenter) }
  let(:group_presenter) { instance_double(Arclight::ShowPresenter, fields_to_render: [double]) }

  it 'has navigation links' do
    expect(page).to have_link 'Summary'
    expect(page).to have_link 'Background'
    expect(page).to have_link 'Related'
    expect(page).to have_link 'Indexed terms'
    expect(page).to have_link 'Access and use'
  end
end
