# frozen_string_literal: true

module Arclight
  # Display the document hierarchy as "breadcrumbs"
  class BreadcrumbComponent < ViewComponent::Base
    # @param [Integer] count if provided the number of bookmarks is limited to this number
    def initialize(document:, count: nil, offset: 0)
      @document = document
      @count = count
      @offset = offset
      super()
    end

    def call
      return unless breadcrumb_links.any?

      tag.ol class: 'breadcrumb' do
        safe_join(breadcrumb_links)
      end
    end

    def components
      return to_enum(:components) unless block_given?

      yield build_repository_link

      @document.parents.each do |parent|
        yield tag.li(class: 'breadcrumb-item') { link_to(parent.label, solr_document_path(parent.id)) }
      end
    end

    def build_repository_link
      render Arclight::RepositoryBreadcrumbComponent.new(document: @document)
    end

    private

    def breadcrumb_links
      @breadcrumb_links ||= limit_breadcrumb_links(components.drop(@offset))
    end

    def limit_breadcrumb_links(links)
      return links unless @count && links.length > @count

      limited_links = links.first(@count)
      limited_links << tag.li('&hellip;'.html_safe, class: 'breadcrumb-item')
      limited_links
    end
  end
end
