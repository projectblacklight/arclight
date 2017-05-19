# frozen_string_literal: true

Arclight::Engine.routes.draw do
  get 'collections' => 'catalog#index', defaults: { f: { level_sim: ['Collection'] } }, as: :collections
  resources :repositories, only: %i[index show], controller: 'arclight/repositories'
end
