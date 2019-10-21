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

  describe '#facet_limit_for' do
    let(:blacklight_config) { controller.blacklight_config }

    it 'defaults to a limit of 10 for shown field facets' do
      expect(blacklight_config.facet_fields.key?('collection_sim')).to be true
      expect(blacklight_config.facet_fields['collection_sim'].limit).to eq 10
      expect(controller.facet_limit_for('collection_sim')).to eq 10

      expect(blacklight_config.facet_fields.key?('creator_ssim')).to be true
      expect(blacklight_config.facet_fields['creator_ssim'].limit).to eq 10
      expect(controller.facet_limit_for('creator_ssim')).to eq 10

      expect(blacklight_config.facet_fields.key?('level_sim')).to be true
      expect(blacklight_config.facet_fields['level_sim'].limit).to eq 10
      expect(controller.facet_limit_for('level_sim')).to eq 10

      expect(blacklight_config.facet_fields.key?('names_ssim')).to be true
      expect(blacklight_config.facet_fields['names_ssim'].limit).to eq 10
      expect(controller.facet_limit_for('names_ssim')).to eq 10

      expect(blacklight_config.facet_fields.key?('repository_sim')).to be true
      expect(blacklight_config.facet_fields['repository_sim'].limit).to eq 10
      expect(controller.facet_limit_for('repository_sim')).to eq 10

      expect(blacklight_config.facet_fields.key?('geogname_sim')).to be true
      expect(blacklight_config.facet_fields['geogname_sim'].limit).to eq 10
      expect(controller.facet_limit_for('geogname_sim')).to eq 10

      expect(blacklight_config.facet_fields.key?('access_subjects_ssim')).to be true
      expect(blacklight_config.facet_fields['access_subjects_ssim'].limit).to eq 10
      expect(controller.facet_limit_for('access_subjects_ssim')).to eq 10
    end
  end
end
