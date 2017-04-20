# frozen_string_literal: true
class CatalogController < ApplicationController

  include Blacklight::Catalog

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
      rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1,
    #  # q: '{!term f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'title_ssm'
    config.index.display_type_field = 'level_ssm'
    #config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'thumbnail_path_ss'

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
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'collection_sim', label: 'Collection'
    config.add_facet_field 'creator_sim', label: 'Creator'
    config.add_facet_field 'date_range_sim', label: 'Date range', range: true
    config.add_facet_field 'level_sim', label: 'Level'
    config.add_facet_field 'names_sim', label: 'Names'
    config.add_facet_field 'repository_sim', label: 'Repository'
    config.add_facet_field 'geogname_sim', label: 'Place'
    config.add_facet_field 'access_subjects_sim', label: 'Subject'

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'unitid_ssm', label: 'Unit ID'
    config.add_index_field 'repository_ssm', label: 'Repository'
    config.add_index_field 'unitdate_ssm', label: 'Date'
    config.add_index_field 'creator_ssm', label: 'Creator'
    config.add_index_field 'language_ssm', label: 'Language'
    config.add_index_field 'scopecontent_ssm', label: 'Scope Content'
    config.add_index_field 'extent_ssm', label: 'Physical Description'
    config.add_index_field 'accessrestrict_ssm', label: 'Conditions Governing Access'
    config.add_index_field 'collection_ssm', label: 'Collection Title'
    config.add_index_field 'geogname_ssm', label: 'Place'

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
    config.add_search_field 'all_fields', label: 'All Fields'

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_filing_si asc', label: 'relevance'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'

    ##
    # Arclight Configurations

    config.show.document_presenter_class = Arclight::ShowPresenter

    ##
    # Configuration for partials
    config.index.partials.insert(0, :index_breadcrumb)

    config.show.metadata_partials = [
      :summary_field,
      :access_field,
      :background_field,
      :scope_and_arrangement_field,
      :related_field
    ]

    # Collection Show Page - Summary Section
    config.add_summary_field 'creator_ssm', label: 'Creator'
    config.add_summary_field 'abstract_ssm', label: 'Abstract'
    config.add_summary_field 'extent_ssm', label: 'Extent'
    config.add_summary_field 'language_ssm', label: 'Language'
    config.add_summary_field 'prefercite_ssm', label: 'Preferred citation'

    # Collection Show Page - Access Section
    config.add_access_field 'accessrestrict_ssm', label: 'Conditions Governing Access'
    config.add_access_field 'userestrict_ssm', label: 'Terms Of Use'

    # Collection Show Page - Background Section
    config.add_background_field 'bioghist_ssm', label: 'Biographical / Historical'

    # Collection Show Page - Scope and Arrangement Section
    config.add_scope_and_arrangement_field 'scopecontent_ssm', label: 'Scope and Content'
    config.add_scope_and_arrangement_field 'arrangement_ssm', label: 'Arrangement'

    # Collection Show Page - Related Section
    config.add_related_field 'relatedmaterial_ssm', label: 'Related material'
    config.add_related_field 'separatedmaterial_ssm', label: 'Separated material'
    config.add_related_field 'otherfindaid_ssm', label: 'Other finding aids'
    config.add_related_field 'altformavail_ssm', label: 'Alternative form available'
    config.add_related_field 'originalsloc_ssm', label: 'Location of originals'
  end
end
