# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include Arclight::Catalog

  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 10,
      fl: '*,collection:[subquery]',
      'collection.q': '{!terms f=id v=$row._root_}',
      'collection.defType': 'lucene',
      'collection.fl': '*',
      'collection.rows': 1
    }

    # Sets the indexed Solr field that will display with highlighted matches
    config.highlight_field = 'text'

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr.
    ## These settings are the Blacklight defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
     qt: 'document',
     fl: '*,collection:[subquery]',
     'collection.q': '{!terms f=id v=$row._root_}',
     'collection.defType': 'lucene',
     'collection.fl': '*',
     'collection.rows': 1
    }

    config.header_component = Arclight::HeaderComponent
    config.add_results_document_tool(:online, component: Arclight::OnlineStatusIndicatorComponent)
    config.add_results_document_tool(:arclight_bookmark_control, component: Arclight::BookmarkComponent)

    config.add_results_collection_tool(:group_toggle)
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for search results/index views
    config.index.partials = %i[arclight_index_default]
    config.index.title_field = 'normalized_title_ssm'
    config.index.display_type_field = 'level_ssm'
    config.index.document_component = Arclight::SearchResultComponent
    config.index.group_component = Arclight::GroupComponent
    config.index.constraints_component = Arclight::ConstraintsComponent
    config.index.document_presenter_class = Arclight::IndexPresenter
    config.index.search_bar_component = Arclight::SearchBarComponent
    # config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr field configuration for document/show views
    # config.show.title_field = 'title_display'
    config.show.document_component = Arclight::DocumentComponent
    config.show.sidebar_component = Arclight::SidebarComponent
    config.show.breadcrumb_component = Arclight::BreadcrumbsHierarchyComponent
    config.show.embed_component = Arclight::EmbedComponent
    config.show.access_component = Arclight::AccessComponent
    config.show.online_status_component = Arclight::OnlineStatusIndicatorComponent
    config.show.display_type_field = 'level_ssm'
    # config.show.thumbnail_field = 'thumbnail_path_ss'
    config.show.document_presenter_class = Arclight::ShowPresenter
    config.show.metadata_partials = %i[
      summary_field
      background_field
      related_field
      indexed_terms_field
      access_field
    ]

    config.show.collection_access_items = %i[
      terms_field
      cite_field
      in_person_field
      contact_field
    ]

    config.show.component_metadata_partials = %i[
      component_field
      component_indexed_terms_field
    ]

    config.show.component_access_items = %i[
      component_terms_field
      cite_field
      in_person_field
      contact_field
    ]

    ##
    # Compact index view
    config.view.compact!

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically
    #  across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation
    #  (note: It is case sensitive when searching values)

    config.add_facet_field 'collection', field: 'collection_ssim', limit: 10
    config.add_facet_field 'creator', field: 'creator_ssim', limit: 10
    config.add_facet_field 'date_range', field: 'date_range_ssim', range: true
    config.add_facet_field 'level', field: 'level_ssim', limit: 10
    config.add_facet_field 'names', field: 'names_ssim', limit: 10
    config.add_facet_field 'repository', field: 'repository_ssim', limit: 10
    config.add_facet_field 'place', field: 'geogname_ssim', limit: 10
    config.add_facet_field 'subject', field: 'access_subjects_ssim', limit: 10

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'highlight', accessor: 'highlights', separator_options: {
      words_connector: '<br/>',
      two_words_connector: '<br/>',
      last_word_connector: '<br/>'
    }, compact: true, component: Arclight::IndexMetadataFieldComponent
    config.add_index_field 'creator', accessor: true, component: Arclight::IndexMetadataFieldComponent
    config.add_index_field 'abstract_or_scope', accessor: true, truncate: true, repository_context: true, helper_method: :render_html_tags, component: Arclight::IndexMetadataFieldComponent
    config.add_index_field 'breadcrumbs', accessor: :itself, component: Arclight::SearchResultBreadcrumbsComponent, compact: { count: 2 }

    config.add_facet_field 'access', query: {
      online: { label: 'Online access', fq: 'has_online_content_ssim:true' }
    }

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field 'all_fields', label: 'All Fields' do |field|
      field.include_in_simple_select = true
    end

    config.add_search_field 'within_collection' do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        fq: '-level_ssim:Collection'
      }
    end

    # Field-based searches. We have registered handlers in the Solr configuration
    # so we have Blacklight use the `qt` parameter to invoke them
    config.add_search_field 'keyword', label: 'Keyword' do |field|
      field.qt = 'search' # default
    end
    config.add_search_field 'name', label: 'Name' do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf:  '${qf_name}',
        pf:  '${pf_name}'
      }
    end
    config.add_search_field 'place', label: 'Place' do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf:  '${qf_place}',
        pf:  '${pf_place}'
      }
    end
    config.add_search_field 'subject', label: 'Subject' do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf:  '${qf_subject}',
        pf:  '${pf_subject}'
      }
    end
    config.add_search_field 'title', label: 'Title' do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf:  '${qf_title}',
        pf:  '${pf_title}'
      }
    end

    # These are the parameters passed through in search_state.params_for_search
    config.search_state_fields += %i[id group hierarchy_context original_document]
    config.search_state_fields << { original_parents: [] }

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_sort asc', label: 'relevance'
    config.add_sort_field 'date_sort asc', label: 'date (ascending)'
    config.add_sort_field 'date_sort desc', label: 'date (descending)'
    config.add_sort_field 'creator_sort asc', label: 'creator (A-Z)'
    config.add_sort_field 'creator_sort desc', label: 'creator (Z-A)'
    config.add_sort_field 'title_sort asc', label: 'title (A-Z)'
    config.add_sort_field 'title_sort desc', label: 'title (Z-A)'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'


    # ===========================
    # COLLECTION SHOW PAGE FIELDS
    # ===========================

    # Collection Show Page - Summary Section
    config.add_summary_field 'creators', field: 'creators_ssim', link_to_facet: true
    config.add_summary_field 'abstract', field: 'abstract_html_tesm', helper_method: :render_html_tags
    config.add_summary_field 'extent', field: 'extent_ssm'
    config.add_summary_field 'language', field: 'language_ssim'
    config.add_summary_field 'prefercite', field: 'prefercite_html_tesm', helper_method: :render_html_tags

    # Collection Show Page - Background Section
    config.add_background_field 'scopecontent', field: 'scopecontent_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'bioghist', field: 'bioghist_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'acqinfo', field: 'acqinfo_ssim', helper_method: :render_html_tags
    config.add_background_field 'appraisal', field: 'appraisal_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'custodhist', field: 'custodhist_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'processinfo', field: 'processinfo_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'arrangement', field: 'arrangement_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'accruals', field: 'accruals_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'phystech', field: 'phystech_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'physloc', field: 'physloc_html_tesm', helper_method: :render_html_tags
    config.add_background_field 'descrules', field: 'descrules_ssm', helper_method: :render_html_tags

    # Collection Show Page - Related Section
    config.add_related_field 'relatedmaterial', field: 'relatedmaterial_html_tesm', helper_method: :render_html_tags
    config.add_related_field 'separatedmaterial', field: 'separatedmaterial_html_tesm', helper_method: :render_html_tags
    config.add_related_field 'otherfindaid', field: 'otherfindaid_html_tesm', helper_method: :render_html_tags
    config.add_related_field 'altformavail', field: 'altformavail_html_tesm', helper_method: :render_html_tags
    config.add_related_field 'originalsloc', field: 'originalsloc_html_tesm', helper_method: :render_html_tags

    # Collection Show Page - Indexed Terms Section
    config.add_indexed_terms_field 'access_subjects', field: 'access_subjects_ssim', link_to_facet: true, separator_options: {
      words_connector: '<br/>',
      two_words_connector: '<br/>',
      last_word_connector: '<br/>'
    }

    config.add_indexed_terms_field 'names_coll', field: 'names_coll_ssim', separator_options: {
      words_connector: '<br/>',
      two_words_connector: '<br/>',
      last_word_connector: '<br/>'
    }, helper_method: :link_to_name_facet

    config.add_indexed_terms_field 'places', field: 'places_ssim', link_to_facet: true, separator_options: {
      words_connector: '<br/>',
      two_words_connector: '<br/>',
      last_word_connector: '<br/>'
    }

    # ==========================
    # COMPONENT SHOW PAGE FIELDS
    # ==========================

    # Component Show Page - Metadata Section
    config.add_component_field 'containers', accessor: 'containers', separator_options: {
      words_connector: ', ',
      two_words_connector: ', ',
      last_word_connector: ', '
    }, if: lambda { |_context, _field_config, document|
      document.containers.present?
    }
    config.add_component_field 'abstract', field: 'abstract_html_tesm', helper_method: :render_html_tags
    config.add_component_field 'extent', field: 'extent_ssm'
    config.add_component_field 'scopecontent', field: 'scopecontent_html_tesm', helper_method: :render_html_tags
    config.add_component_field 'acqinfo', field: 'acqinfo_ssim', helper_method: :render_html_tags
    config.add_component_field 'appraisal', field: 'appraisal_html_tesm', helper_method: :render_html_tags
    config.add_component_field 'custodhist', field: 'custodhist_html_tesm', helper_method: :render_html_tags
    config.add_component_field 'processinfo', field: 'processinfo_html_tesm', helper_method: :render_html_tags
    config.add_component_field 'arrangement', field: 'arrangement_html_tesm', helper_method: :render_html_tags
    config.add_component_field 'accruals', field: 'accruals_html_tesm', helper_method: :render_html_tags
    config.add_component_field 'phystech', field: 'phystech_html_tesm', helper_method: :render_html_tags
    config.add_component_field 'physloc', field: 'physloc_html_tesm', helper_method: :render_html_tags

    # Component Show Page - Indexed Terms Section
    config.add_component_indexed_terms_field 'access_subjects', field: 'access_subjects_ssim', link_to_facet: true, separator_options: {
      words_connector: '<br/>',
      two_words_connector: '<br/>',
      last_word_connector: '<br/>'
    }

    config.add_component_indexed_terms_field 'names', field: 'names_ssim', separator_options: {
      words_connector: '<br/>',
      two_words_connector: '<br/>',
      last_word_connector: '<br/>'
    }, helper_method: :link_to_name_facet

    config.add_component_indexed_terms_field 'places', field: 'places_ssim', link_to_facet: true, separator_options: {
      words_connector: '<br/>',
      two_words_connector: '<br/>',
      last_word_connector: '<br/>'
    }

    # =================
    # ACCESS TAB FIELDS
    # =================

    # Collection Show Page Access Tab - Terms and Conditions Section
    config.add_terms_field 'restrictions', field: 'accessrestrict_html_tesm', helper_method: :render_html_tags
    config.add_terms_field 'terms', field: 'userestrict_html_tesm', helper_method: :render_html_tags

    # Component Show Page Access Tab - Terms and Condition Section
    config.add_component_terms_field 'restrictions', field: 'accessrestrict_html_tesm', helper_method: :render_html_tags
    config.add_component_terms_field 'terms', field: 'userestrict_html_tesm', helper_method: :render_html_tags
    config.add_component_terms_field 'parent_restrictions', field: 'parent_access_restrict_tesm', helper_method: :render_html_tags
    config.add_component_terms_field 'parent_terms', field: 'parent_access_terms_tesm', helper_method: :render_html_tags

    # Collection and Component Show Page Access Tab - In Person Section
    config.add_in_person_field 'repository_location', values: ->(_, document, _) { document.repository_config }, component: Arclight::RepositoryLocationComponent
    config.add_in_person_field 'before_you_visit', values: ->(_, document, _) { document.repository_config&.visit_note }

    # Collection and Component Show Page Access Tab - How to Cite Section
    config.add_cite_field 'prefercite', field: 'prefercite_html_tesm', helper_method: :render_html_tags

    # Collection and Component Show Page Access Tab - Contact Section
    config.add_contact_field 'repository_contact', values: ->(_, document, _) { document.repository_config&.contact }

    # Group header values
    config.add_group_header_field 'abstract_or_scope', accessor: true, truncate: true, helper_method: :render_html_tags
  end
end
