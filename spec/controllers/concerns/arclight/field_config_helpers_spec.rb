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
    SolrDocument.new(repository_ssm: ['Stanford University Libraries. Special Collections and University Archives'])
  end

  describe '#repository_config_present' do
    it 'is true when the repository configuration is present' do
      expect(
        helper.repository_config_present(nil, document_with_repository)
      ).to be true
    end

    it 'is false when there is no repository configuration present' do
      expect(
        helper.repository_config_present(nil, document_without_repository)
      ).to be false
    end
  end

  describe '#request_config_present' do
    context 'when repository_config is present' do
      it do
        expect(helper.request_config_present(nil, document_with_repository)).to be true
      end
      context 'when no request config is present' do
        it do
          expect(helper.request_config_present(nil, document_without_request)).to be false
        end
      end
    end
    context 'when repository_config is absent' do
      it do
        expect(helper.repository_config_present(nil, document_without_repository)).to be false
      end
    end
  end

  describe '#context_sidebar_repository' do
    it 'renders the in_person_repository partial' do
      content = Capybara.string(helper.context_sidebar_repository(document: document_with_repository))
      expect(content).to have_css('.al-in-person-repository-name', text: 'My Repository')
      expect(content).to have_css('address .al-repository-contact-building', text: 'My Building')
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

  describe '#context_sidebar_visit_note' do
    it 'is returns the visit note' do
      content = helper.context_sidebar_visit_note(document: document_with_repository)
      expect(content).to eq 'Containers are stored offsite and must be pages 2 to 3 days in advance'
    end
  end
end
