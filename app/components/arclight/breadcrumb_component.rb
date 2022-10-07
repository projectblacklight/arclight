# frozen_string_literal: true

module Arclight
  # Display the document hierarchy as "breadcrumbs"
  class BreadcrumbComponent < ViewComponent::Base
    def initialize(document:, count: nil, offset: 0, separator: nil)
      @document = document
      @count = count
      @offset = offset
      @breadcrumb_separator = separator

      super
    end

    def call
      breadcrumb_links = components.drop(@offset)

      if @count && breadcrumb_links.length > @count
        breadcrumb_links = breadcrumb_links.first(@count)
        breadcrumb_links << '&hellip;'.html_safe
      end

      safe_join(breadcrumb_links, breadcrumb_separator)
    end

    def components
      return to_enum(:components) unless block_given?

      yield build_repository_link

      @document.parents.each do |parent|
        yield link_to(parent.label, solr_document_path(parent.global_id))
      end
    end

    def breadcrumb_separator
      @breadcrumb_separator ||= tag.span(t('arclight.breadcrumb_separator'), aria: { hidden: true })
    end

    def build_repository_link
      repository_path = @document.repository_config&.slug
      if repository_path.present?
        link_to(@document.repository, helpers.arclight_engine.repository_path(repository_path))
      else
        tag.span(@document.repository)
      end
    end
  end
end
