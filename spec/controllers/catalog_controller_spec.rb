# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'index action customizations' do
    context 'hierarchy view' do
      it 'does not start a search_session' do
        allow(controller).to receive(:search_results)
        session[:history] = []
        get :index, params: { q: 'foo', view: 'hierarchy' }
        expect(session[:history]).to be_empty
      end
      it 'does not store a preferred_view' do
        allow(controller).to receive(:search_results)
        session[:preferred_view] = 'list'
        get :index, params: { q: 'foo', view: 'hierarchy' }
        expect(session[:preferred_view]).to eq 'list'
      end
    end

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
end
