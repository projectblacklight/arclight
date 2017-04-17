# frozen_string_literal: true

module Arclight
  ##
  # Object for parsing and formalizing Solr_Ead "Parents"
  # https://github.com/awead/solr_ead/blob/8cf7ffaa66e0e4c9c0b12f5646d6c2e20984cd99/lib/solr_ead/behaviors.rb#L54-L57
  class Parents
    attr_reader :ids, :labels, :eadid
    def initialize(ids:, labels:, eadid:)
      @ids = ids
      @labels = labels
      @eadid = eadid
    end

    ##
    # @return [Array[Arclight::Parent]]
    def as_parents
      Hash[ids.zip(labels)].map { |k, v| Arclight::Parent.new(id: k, label: v, eadid: eadid) }
    end

    ##
    # @param [SolrDocument] document
    def self.from_solr_document(document)
      ids = document.fetch('parent_ssm', [])
      labels = document.fetch('parent_unittitles_ssm', [])
      eadid = document.fetch('ead_ssi', '')
      new(ids: ids, labels: labels, eadid: eadid)
    end
  end
end
