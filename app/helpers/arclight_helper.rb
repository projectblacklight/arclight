# frozen_string_literal: true

##
# Generic Helpers used in Arclight
module ArclightHelper
  include Arclight::EadFormatHelpers
  include Arclight::FieldConfigHelpers
  include Blacklight::LayoutHelperBehavior

  def repository_collections_path(repository)
    search_action_url(
      f: {
        repository_sim: [repository.name],
        level_sim: ['Collection']
      }
    )
  end

  # Returns the i18n-ed string to be used as the h1 in search results
  def search_results_header_text
    if (repo = repository_faceted_on).present?
      t('arclight.search.repository_header', repository: repo.name)
    elsif collection_active?
      t('arclight.search.collections_header')
    else
      t('blacklight.search.header')
    end
  end

  ##
  # Classes used for customized show page in arclight
  def show_content_classes
    'col-8 show-document order-2'
  end

  def show_sidebar_classes
    'col-4 order-1 collection-sidebar'
  end

  def collection_active?
    search_state.filter('level_sim').values == ['Collection']
  end

  def collection_active_class
    'active' if collection_active?
  end

  def grouped?
    respond_to?(:search_state) && search_state&.params_for_search&.dig('group') == 'true'
  end

  def search_with_group
    search_state.params_for_search.merge('group' => 'true').except('page')
  end

  def search_without_group
    search_state.params_for_search.except('group', 'page')
  end

  def on_repositories_show?
    controller_name == 'repositories' && action_name == 'show'
  end

  def on_repositories_index?
    controller_name == 'repositories' && action_name == 'index'
  end

  # the Repositories menu item is only active on the Repositories index page
  def repositories_active_class
    'active' if on_repositories_index?
  end

  # If we have a facet on the repository, then return the Repository object for it
  #
  # @return [Repository]
  def repository_faceted_on
    repos = search_state.filter('repository_sim').values
    return unless repos.one?

    Arclight::Repository.find_by(name: repos.first)
  end

  # determine which icon to show in search results header
  # these icon names will need to be updated when the icons are determined
  def document_or_parent_icon(document)
    case document.level&.downcase
    when 'collection'
      'collection'
    when 'file'
      'file'
    when 'series', 'subseries'
      'folder'
    else
      'container'
    end
  end

  def show_expanded?(document)
    !original_document?(document) && within_original_tree?(document)
  end

  def within_original_tree?(document)
    Array.wrap(params['original_parents']).map do |parent|
      Arclight::Parent.new(id: parent, eadid: document.parent_ids.first, level: nil, label: nil).global_id
    end.include?(document.id)
  end

  def original_document?(document)
    document.id == params['original_document']
  end

  # rubocop:disable Metrics/MethodLength
  def generic_context_navigation(document, original_parents: document.parent_ids, component_level: 1)
    content_tag(
      :div,
      '',
      class: 'context-navigator',
      data: {
        collapse: I18n.t('arclight.views.show.collapse'),
        expand: I18n.t('arclight.views.show.expand'),
        controller: 'arclight-context-navigation',
        arclight: {
          level: component_level,
          path: search_catalog_path(hierarchy_context: 'component'),
          name: document.collection_name,
          originalDocument: document.id,
          originalParents: original_parents,
          eadid: document.normalized_eadid
        }
      }
    )
  end
  # rubocop:enable Metrics/MethodLength

  def current_context_document
    @document
  end
end
