# frozen_string_literal: true

module Arclight
  ##
  # A simple wrapper class around the SolrEad::Indexer so we can add our own behavior
  class Indexer < SolrEad::Indexer
    include Arclight::SolrEadIndexerExt
  end
end
