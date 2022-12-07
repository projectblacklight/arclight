# frozen_string_literal: true

# Root crumb
crumb :root do
  link t('arclight.routes.home'), root_path
end

crumb :repositories do
  link t('arclight.routes.repositories'), arclight_engine.repositories_path
end

crumb :repository do |repository|
  link repository.name, arclight_engine.repository_path(repository.slug)

  parent :repositories
end

crumb :search_results do |search_state|
  if search_state.filter('level').values == ['Collection']
    link t('arclight.routes.collections')
  else
    link t('arclight.routes.search_results')
  end
end
