# frozen_string_literal: true

module Arclight
  ##
  # Extends Blacklight::Solr::Document to provide Arclight specific behavior
  module SolrDocument
    extend Blacklight::Solr::Document

    def parent_ids
      fetch('parent_ssm', [])
    end

    def parent_labels
      fetch('parent_unittitles_ssm', [])
    end

    def eadid
      fetch('ead_ssi', nil)
    end
  end
end
