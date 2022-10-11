# frozen_string_literal: true

require 'digest'

module Arclight
  ##
  # Take a Nokogiri node and get its absolute path (inserting our own indexes for component levels)
  # and hash that outout. This is intended as a potential strategy for handling missing IDs in EADs.
  class HashAbsoluteXpath
    class << self
      attr_writer :hash_algorithm

      def hash_algorithm
        return Digest::SHA1 unless defined? @hash_algorithm

        @hash_algorithm
      end
    end

    COMPONENT_NODE_NAME_REGEX = /^c\d{,2}$/
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def to_hexdigest
      self.class.hash_algorithm.hexdigest(absolute_xpath).prepend('al_')
    end

    def absolute_xpath
      ancestor_tree = node.ancestors.map do |ancestor|
        ancestor_name_and_index(ancestor)
      end

      "#{[ancestor_tree.reverse, node.name].flatten.join('/')}#{current_index}"
    end

    private

    def current_index
      siblings.index(node)
    end

    def component_siblings_for_node(xml_node)
      xml_node.parent.children.select { |n| n.name =~ COMPONENT_NODE_NAME_REGEX }
    end

    def siblings
      @siblings ||= component_siblings_for_node(node)
    end

    def ancestor_name_and_index(ancestor)
      if ancestor.name =~ COMPONENT_NODE_NAME_REGEX
        index = component_siblings_for_node(ancestor).index(ancestor)
        "#{ancestor.name}#{index}"
      else
        ancestor.name
      end
    end
  end
end
