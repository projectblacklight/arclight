# frozen_string_literal: true

module Arclight
  ##
  # Object for parsing and formalizing Solr_Ead "Parents"
  # https://github.com/awead/solr_ead/blob/8cf7ffaa66e0e4c9c0b12f5646d6c2e20984cd99/lib/solr_ead/behaviors.rb#L54-L57
  class Parents
    attr_reader :ids, :labels, :levels
    def initialize(ids:, labels:, eadid:, levels:)
      @ids = ids
      @labels = labels
      @eadid = eadid
      @levels = levels
    end

    def eadid
      Arclight::NormalizedId.new(@eadid).to_s
    end

    ##
    # @return [Array[Arclight::Parent]]
    def as_parents
      ids.map.with_index { |_id, idx| Arclight::Parent.new(id: ids[idx], label: labels[idx], eadid: eadid, level: levels[idx]) }
    end

    ##
    # @param [SolrDocument] document
    def self.from_solr_document(document)
      ids = document.parent_ids
      labels = document.parent_labels
      eadid = document.eadid
      levels = document.parent_levels
      new(ids: ids, labels: labels, eadid: eadid, levels: levels)
    end
  end
end
