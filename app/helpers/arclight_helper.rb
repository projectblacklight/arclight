# frozen_string_literal: true

##
# Generic Helpers used in Arclight
module ArclightHelper
  include Arclight::EadFormatHelpers
  include Arclight::FieldConfigHelpers

  def aria_hidden_breadcrumb_separator
    tag.span t('arclight.breadcrumb_separator'), aria: { hidden: true }
  end

  def breadcrumb_links(*components, count: -1, separator: aria_hidden_breadcrumb_separator)
    breadcrumb_links = components.flatten.compact
    if count.positive? && breadcrumb_links.length > count
      breadcrumb_links = breadcrumb_links.first(count)
      breadcrumb_links << '&hellip;'.html_safe
    end

    safe_join(breadcrumb_links, separator)
  end

  ##
  # @param [SolrDocument]
  def parents_to_links(document, **kwargs)
    parent_links = document_parents(document).map do |parent|
      link_to parent.label, solr_document_path(parent.global_id)
    end

    breadcrumb_links(build_repository_link(document), parent_links, **kwargs)
  end

  ##
  # For a non-grouped compact view, display the breadcrumbs with the following
  # algorithm:
  #  - Display only the first two parts of the item breadcrumb: the repository
  #    and the collection.
  #  - After the collection and the breadcrumb divider icon, show an ellipses as
  #    shown in the mockup above. The repository and the collection parts are
  #    linked as usual; the ellipses is not linked.
  def regular_compact_breadcrumbs(document)
    parents_to_links(document, count: 2)
  end

  ##
  # @param [SolrDocument]
  def component_parents_to_links(document, offset: 1, **kwargs)
    parent_links = document_parents(document).slice(offset, 999)&.map do |parent|
      link_to parent.label, solr_document_path(parent.global_id)
    end

    breadcrumb_links(parent_links, **kwargs) if parent_links&.any?
  end

  ##
  # @param [SolrDocument]
  def component_top_level_parent_to_links(document)
    component_parents_to_links(document, count: 1)
  end

  ##
  # @param [SolrDocument]
  def document_parents(document)
    document.parents
  end

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
  def custom_show_content_classes
    'col-md-12 show-document'
  end

  def normalize_id(id)
    Arclight::NormalizedId.new(id).to_s
  end

  def collection_active?
    respond_to?(:search_state) && search_state&.params_for_search&.dig('f', 'level_sim') == ['Collection']
  end

  def collection_active_class
    'active' if collection_active?
  end

  def collection_count
    @response.response['numFound']
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

  def search_within_collection(collection_name, search)
    search.merge(f: { collection_sim: [collection_name] })
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

  def hierarchy_component_context?
    params[:hierarchy_context] == 'component'
  end

  def online_contents_context?
    params[:view] == 'online_contents'
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

  def render_grouped_documents(documents)
    safe_join(
      documents.each_with_index.map do |document, i|
        render_document_partial(document, :arclight_index_group_document, document_counter: i)
      end
    )
  end

  def ead_files(document)
    files = Arclight::DocumentDownloads.new(document, document.collection_unitid).files
    files.find do |file|
      file.type == 'ead'
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

  def generic_context_navigation(document, original_parents: document.parent_ids, component_level: 1)
    content_tag(
      :div,
      '',
      class: 'context-navigator',
      data: {
        collapse: I18n.t('arclight.views.show.collapse'),
        expand: I18n.t('arclight.views.show.expand'),
        arclight: {
          level: component_level,
          path: search_catalog_path(hierarchy_context: 'component'),
          name: document.collection_name,
          originalDocument: document.id,
          originalParents: original_parents,
          eadid: normalize_id(document.eadid)
        }
      }
    )
  end

  ##
  # Determine if the user is currently under a collection context
  # This is any record view (because it is either the collection or a component w/i a collection)
  # or in a result view where a collection facet has been selected
  def within_collection_context?
    return true if record_view?

    results_view? && params.dig(:f, 'collection_sim')
  end

  def results_view?
    controller_name == 'catalog' && action_name == 'index'
  end

  def record_view?
    controller_name == 'catalog' && action_name == 'show'
  end

  private

  def build_repository_link(document)
    repository_path = document.repository_config&.slug
    if repository_path.present?
      link_to(document.repository, arclight_engine.repository_path(repository_path))
    else
      content_tag(:span, document.repository)
    end
  end
end
