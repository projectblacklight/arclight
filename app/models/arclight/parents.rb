# frozen_string_literal: true

module Arclight
  ##
  # Object for parsing and formalizing Solr_Ead "Parents"
  # https://github.com/awead/solr_ead/blob/8cf7ffaa66e0e4c9c0b12f5646d6c2e20984cd99/lib/solr_ead/behaviors.rb#L54-L57
  class Parents
    attr_reader :ids, :legacy_ids, :labels, :levels

    def initialize(ids:, legacy_ids:, labels:, eadid:, levels:)
      @ids = ids
      @legacy_ids = legacy_ids
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
      (ids.presence || legacy_ids).map.with_index { |id, idx| Arclight::Parent.new(id: id, label: labels[idx], eadid: eadid, level: levels[idx]) }
    end

    ##
    # @param [SolrDocument] document
    def self.from_solr_document(document)
      ids = document.parent_ids
      legacy_ids = document.legacy_parent_ids.map { |legacy_id| document.root == legacy_id ? legacy_id : "#{document.root}#{legacy_id}" }
      labels = document.parent_labels
      eadid = document.eadid
      levels = document.parent_levels
      new(ids: ids, legacy_ids: legacy_ids, labels: labels, eadid: eadid, levels: levels)
    end
  end
end
