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
      content = Capybara.string(helper.context_access_tab_repository(document: document_with_repository))
      expect(content).to have_css('.al-in-person-repository-name', text: 'My Repository')
      expect(content).to have_css('address .al-repository-street-address-building', text: 'My Building')
    end
  end

  describe '#before_you_visit_note_present' do
    it 'is true when the visit note is present in the config' do
      expect(
        helper.before_you_visit_note_present(nil, document_with_repository)
      ).to be true
    end

    it 'is false when there is no visit note in the config' do
      expect(
        helper.before_you_visit_note_present(nil, document_without_visit_note)
      ).to be false
    end

    it 'is falsey when there is no config' do
      expect(
        helper.before_you_visit_note_present(nil, document_without_repository)
      ).to be_falsey
    end
  end

  describe '#context_access_tab_visit_note' do
    it 'is returns the visit note' do
      content = helper.context_access_tab_visit_note(document: document_with_repository)
      expect(content).to eq 'Containers are stored offsite and must be pages 2 to 3 days in advance'
    end
  end
end
