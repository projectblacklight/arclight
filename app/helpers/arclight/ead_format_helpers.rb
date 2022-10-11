# frozen_string_literal: true

module Arclight
  ##
  # A module to add EAD to HTML transformation rules for Arclight
  module EadFormatHelpers # rubocop:disable Metrics/ModuleLength
    extend ActiveSupport::Concern

    def render_html_tags(args)
      values = Array(args[:value])
      values.map! do |value|
        transform_ead_to_html(value)
      end
      values.map! { |value| wrap_in_paragraph(value) } if values.count > 1
      safe_join(values.map(&:html_safe))
    end

    private

    def transform_ead_to_html(value)
      Loofah.xml_fragment(condense_whitespace(value))
            .scrub!(ead_to_html_scrubber)
            .scrub!(:strip).to_html
    end

    def ead_to_html_scrubber
      Loofah::Scrubber.new do |node|
        format_render_attributes(node) if node.attr('render').present?
        format_lists(node) if %w[list chronlist].include? node.name
        node
      end
    end

    def condense_whitespace(str)
      str.squish.strip.gsub(/>[\n\s]+</, '><')
    end

    def wrap_in_paragraph(value)
      if value.start_with?('<')
        value
      else
        content_tag(:p, value)
      end
    end

    def format_render_attributes(node) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
      case node.attr('render')
      when 'altrender'
        node.name = 'span'
        node['class'] = node['altrender']
      when 'bold'
        node.name = 'strong'
      when 'bolddoublequote'
        node.name = 'strong'
        node.prepend_child '"'
        node.add_child '"'
      when 'bolditalic'
        node.name = 'strong'
        node.wrap('<em/>')
      when 'boldsinglequote'
        node.name = 'strong'
        node.prepend_child '\''
        node.add_child '\''
      when 'boldsmcaps'
        node.name = 'strong'
        node.wrap('<small/>')
        node['class'] = 'text-uppercase'
      when 'boldunderline'
        node.name = 'strong'
        node['class'] = 'text-underline'
      when 'doublequote'
        node.name = 'span'
        node.prepend_child '"'
        node.add_child '"'
      when 'italic', 'nonproport'
        node.name = 'em'
      when 'singlequote'
        node.name = 'span'
        node.prepend_child '\''
        node.add_child '\''
      when 'smcaps'
        node.name = 'small'
        node['class'] = 'text-uppercase'
      when 'sub'
        node.name = 'sub'
      when 'super'
        node.name = 'sup'
      when 'underline'
        node.name = 'span'
        node['class'] = 'text-underline'
      end
    end

    def format_lists(node)
      format_simple_lists(node) if node.name == 'list' && node['type'] != 'deflist'
      format_deflists(node) if node.name == 'list' && node['type'] == 'deflist'
      format_chronlists(node) if node.name == 'chronlist'
    end

    def format_simple_lists(node)
      node.name = 'ul' if (%w[simple marked].include? node['type']) || node['type'].blank?
      node.name = 'ol' if node['type'] == 'ordered'
      node.remove_attribute('type')
      head_node = node.at_css('head')
      format_list_head(head_node) if head_node.present?
      items = node.css('item')
      items.each { |item_node| item_node.name = 'li' }
    end

    def format_list_head(node)
      node['class'] = 'list-head'
      node.name = 'div'
      node.parent.previous = node # move it from within the list to above it
    end

    def format_deflists(node)
      listhead_node = node.at_css('listhead')
      labels = node.css('label')
      items = node.css('item')
      defitems = node.css('defitem')
      node.remove_attribute('type')

      if listhead_node.present?
        format_deflist_as_table(node, labels, items, defitems)
      else
        format_deflist_as_dl(node, labels, items, defitems)
      end
    end

    def format_deflist_as_table(node, labels, items, defitems)
      node.name = 'table'
      node['class'] = 'table deflist'
      listhead_node = node.at_css('listhead')
      format_deflist_table_head(listhead_node)
      node.at_css('thead').next = '<tbody/>'
      labels.each { |label_node| label_node.name = 'td' }
      items.each { |item_node| item_node.name = 'td' }
      defitems.each do |defitem_node|
        defitem_node.name = 'tr'
        defitem_node.parent = node.at_css('tbody')
      end
    end

    def format_deflist_table_head(listhead_node)
      listhead_node.at_css('head01').name = 'th'
      listhead_node.at_css('head02').name = 'th'
      listhead_node.name = 'tr'
      listhead_node.wrap('<thead/>')
    end

    def format_deflist_as_dl(node, labels, items, defitems)
      node.name = 'dl'
      node['class'] = 'deflist'
      labels.each { |label_node| label_node.name = 'dt' }
      items.each { |item_node| item_node.name = 'dd' }
      defitems.each { |defitem_node| defitem_node.swap(defitem_node.children) } # unwrap
    end

    def format_chronlists(node)
      node.name = 'table'
      node['class'] = 'table chronlist'
      eventgrps = node.css('eventgrp')
      single_events = node.css('chronitem > event')
      multi_events = node.css('eventgrp > event')
      format_chronlist_header(node)
      node.at_css('thead').next = '<tbody/>'
      format_chronlist_caption(node)
      format_chronlist_chronitems(node)
      format_chronlist_dates(node)
      format_chronlist_events(eventgrps, single_events, multi_events)
    end

    def format_chronlist_header(node)
      node.add_child('<thead><tr><th>Date</th><th>Event</th></tr></thead>')
      table_head = node.at_css('thead')
      node.children.first.add_previous_sibling(table_head)
      listhead_node = node.at_css('listhead')
      return if listhead_node.blank?

      node.at_css('thead tr th:nth-of-type(1)').content = node.at_css('listhead/head01').content
      node.at_css('thead tr th:nth-of-type(2)').content = node.at_css('listhead/head02').content
      listhead_node.remove
    end

    def format_chronlist_caption(node)
      head_node = node.at_css('head')
      return if head_node.blank?

      head_node.name = 'caption'
      head_node['class'] = 'chronlist-head'
      node.children.first.add_previous_sibling(head_node) # make the caption first
    end

    def format_chronlist_chronitems(node)
      chronitems = node.css('chronitem')
      chronitems.each do |chronitem_node|
        chronitem_node.name = 'tr'
        chronitem_node.parent = node.at_css('tbody')
      end
    end

    def format_chronlist_dates(node)
      dates = node.css('date')
      dates.each do |date_node|
        date_node.name = 'td'
        date_node['class'] = 'chronlist-item-date'
      end
    end

    def format_chronlist_events(eventgrps, single_events, multi_events)
      eventgrps.each do |eventgrp_node|
        eventgrp_node.name = 'td'
        eventgrp_node['class'] = 'chronlist-item-event'
      end
      single_events.each do |event_node|
        event_node.name = 'td'
        event_node['class'] = 'chronlist-item-event'
      end
      multi_events.each { |event_node| event_node.name = 'div' }
    end
  end
end
