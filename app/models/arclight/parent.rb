# frozen_string_literal: true

module Arclight
  ##
  # Logic containing information about Solr_Ead "Parent"
  # https://github.com/awead/solr_ead/blob/8cf7ffaa66e0e4c9c0b12f5646d6c2e20984cd99/lib/solr_ead/behaviors.rb#L54-L57
  class Parent
    attr_reader :id, :label, :eadid, :level

    def initialize(id:, label:, eadid:, level:)
      @id = id
      @label = label
      @eadid = eadid
      @level = level
    end

    def collection?
      level == 'collection'
    end

    ##
    # Concatenates the eadid and the id, to return an "id" in the context of
    # Blacklight and Solr
    # @return [String]
    def global_id
      return id if eadid == id

      "#{eadid}#{id}"
    end
  end
end
