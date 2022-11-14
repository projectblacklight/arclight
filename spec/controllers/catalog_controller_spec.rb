# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CatalogController do
  describe 'index action customizations' do
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
