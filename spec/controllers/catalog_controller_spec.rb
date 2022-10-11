# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'index action customizations' do
    context 'online_contents view' do
      it 'does not start a search_session' do
        allow(controller).to receive(:search_results)
        session[:history] = []
        get :index, params: { q: 'foo', view: 'online_contents' }
        expect(session[:history]).to be_empty
      end

      it 'does not store a preferred_view' do
        allow(controller).to receive(:search_results)
        session[:preferred_view] = 'list'
        get :index, params: { q: 'foo', view: 'online_contents' }
        expect(session[:preferred_view]).to eq 'list'
      end
    end

    context 'any other view' do
      it 'starts a search_session' do
        allow(controller).to receive(:search_results)
        session[:history] = []
        get :index, params: { q: 'foo', view: 'list' }
        expect(session[:history]).not_to be_empty
      end

      it 'stores a preferred_view' do
        allow(controller).to receive(:search_results)
        session[:preferred_view] = 'list'
        get :index, params: { q: 'foo', view: 'gallery' }
        expect(session[:preferred_view]).to eq 'gallery'
      end
    end
  end

  describe '#repository_config_present' do
    let(:document_with_repository) { SolrDocument.new(repository_ssm: ['My Repository']) }
    let(:document_without_repository) { SolrDocument.new }

    it 'is true when the repository configuration is present' do
      expect(
        controller.repository_config_present?(nil, document_with_repository)
      ).to be true
    end

    it 'is false when there is no repository configuration present' do
      expect(
        controller.repository_config_present?(nil, document_without_repository)
      ).to be false
    end
  end
end
