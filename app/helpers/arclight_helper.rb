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
        repository: [repository.name],
        level: ['Collection']
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
    'col-12 col-lg-8 show-document order-2'
  end

  def show_sidebar_classes
    'col-lg-4 order-1 collection-sidebar'
  end

  def collection_active?
    search_state.filter('level').values == ['Collection']
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
    repos = search_state.filter('repository').values
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

  def current_context_document
    @document
  end
end
