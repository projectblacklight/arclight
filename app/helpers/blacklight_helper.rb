# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  include Blacklight::CatalogHelperBehavior

  ##
  # Override the Blacklight Kaminari Override to better support custom group behavior
  # @param [RSolr::Resource] collection (or other Kaminari-compatible objects)
  # @return [String]
  def page_entries_info(collection, options = {})
    # Return to Blacklight implementation unless collection grouping is enabled
    return super unless collection.respond_to?(:groups) && render_grouped_response?(collection)
    return unless show_pagination? collection

    entry_name = t('arclight.entry_name.grouped', count: collection.total_count)

    end_num = collection.groups.length
    end_num = if collection.offset_value + end_num <= collection.total_count
                collection.offset_value + end_num
              else
                collection.total_count
              end

    case collection.total_count
    when 0
      t('arclight.search.pagination_info.no_items_found', entry_name: entry_name).html_safe
    when 1
      t('arclight.search.pagination_info.single_item_found', entry_name: entry_name).html_safe
    else
      t('arclight.search.pagination_info.pages', entry_name: entry_name,
                                                 current_page: collection.current_page,
                                                 num_pages: collection.total_pages,
                                                 start_num: number_with_delimiter(collection.offset_value + 1),
                                                 end_num: number_with_delimiter(end_num),
                                                 total_num: number_with_delimiter(collection.total_count),
                                                 count: collection.total_pages).html_safe
    end
  end
end
