# frozen_string_literal: true

require 'spec_helper'

class TestController
  include Arclight::FieldConfigHelpers
end

RSpec.describe Arclight::FieldConfigHelpers do
  subject(:helper) { TestController.new }

  let(:document_with_repository) { SolrDocument.new(repository_ssm: ['My Repository']) }
  let(:document_without_visit_note) do
    SolrDocument.new(repository_ssm: ['National Library of Medicine. History of Medicine Division'])
  end
  let(:document_without_repository) { SolrDocument.new }
  let(:document_without_request) do
    SolrDocument.new(repository_ssm: ['Repository with no requestable items'])
  end
  let(:document_with_highlight) do
    SolrDocument.new(accessrestrict_ssm: ['Restricted until 2018.'])
  end

  describe '#context_access_tab_repository' do
    it 'renders the in_person_repository partial' do
      content = Capybara.string(helper.context_access_tab_repository(value: [document_with_repository.repository_config]))
      expect(content).to have_css('.al-in-person-repository-name', text: 'My Repository')
      expect(content).to have_css('address .al-repository-street-address-building', text: 'My Building')
    end
  end
end
