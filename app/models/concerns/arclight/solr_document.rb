# frozen_string_literal: true

module Arclight
  ##
  # Extends Blacklight::Solr::Document to provide Arclight specific behavior
  module SolrDocument
    extend ActiveSupport::Concern

    included do
      attribute :parent_ids, :array, 'parent_ssim'
      attribute :parent_labels, :array, 'parent_unittitles_ssm'
      attribute :parent_levels, :array, 'parent_levels_ssm'
      attribute :unitid, :string, 'unitid_ssm'
      attribute :extent, :string, 'extent_ssm'
      attribute :abstract, :string, 'abstract_html_tesm'
      attribute :scope, :string, 'scopecontent_html_tesm'
      attribute :creator, :string, 'creator_ssm'
      attribute :level, :string, 'level_ssm'
      attribute :terms, :string, 'userestrict_html_tesm'
      # Restrictions for component sidebar
      attribute :parent_restrictions, :string, 'parent_access_restrict_tesm'
      # Terms for component sidebar
      attribute :parent_terms, :string, 'parent_access_terms_tesm'
      attribute :reference, :string, 'ref_ssm'
      attribute :normalized_title, :string, 'normalized_title_ssm'
      attribute :normalized_date, :string, 'normalized_date_ssm'
      attribute :total_component_count, :string, 'total_component_count_is'
      attribute :online_item_count, :string, 'online_item_count_is'
      attribute :last_indexed, :date, 'timestamp'
    end

    def repository_config
      return unless repository

      @repository_config ||= Arclight::Repository.find_by(name: repository)
    end

    def parents
      @parents ||= Arclight::Parents.from_solr_document(self).as_parents
    end

    # Get this document's EAD ID, or fall back to the collection (especially
    # for components that may not have their own.
    def eadid
      first('ead_ssi')&.strip || collection&.first('ead_ssi')&.strip
    end

    def normalized_eadid
      Arclight::NormalizedId.new(eadid).to_s
    end

    def repository
      first('repository_ssm') || collection&.first('repository_ssm')
    end

    def repository_and_unitid
      [repository, unitid].compact.join(': ')
    end

    # @return [SolrDocument] a SolrDocument representing the EAD collection
    #   that this document belongs to
    def collection
      return self if collection?

      @collection ||= self.class.new(self['collection']&.dig('docs', 0), @response)
    end

    def collection_name
      collection&.normalized_title
    end

    def collection_unitid
      collection&.unitid
    end

    def abstract_or_scope
      abstract || scope
    end

    def collection_creator
      collection&.creator
    end

    def online_content?
      first('has_online_content_ssim') == 'true'
    end

    def number_of_children
      first('child_component_count_isi') || 0
    end

    def children?
      number_of_children.positive?
    end

    def component_level
      first('component_level_isim')
    end

    def collection?
      level&.parameterize == 'collection'
    end

    def digital_objects
      digital_objects_field = fetch('digital_objects_ssm', []).reject(&:empty?)
      return [] if digital_objects_field.blank?

      digital_objects_field.map do |object|
        Arclight::DigitalObject.from_json(object)
      end
    end

    def containers
      # NOTE: that .titlecase strips punctuation, like hyphens, we want to keep
      fetch('containers_ssim', []).map(&:capitalize)
    end

    # @return [Array<String>] with embedded highlights using <em>...</em>
    def highlights
      highlight_field(CatalogController.blacklight_config.highlight_field)
    end

    # Factory method for constructing the Object modeling downloads
    # @return [DocumentDownloads]
    def downloads
      @downloads ||= DocumentDownloads.new(self)
    end

    def ead_file
      @ead_file ||= begin
        files = Arclight::DocumentDownloads.new(self, collection_unitid).files
        files.find do |file|
          file.type == 'ead'
        end
      end
    end

    def nest_path
      self['_nest_path_']
    end

    def root
      self['_root_'] || self['id']
    end

    def requestable?
      repository_config&.request_types&.any?
    end
  end
end
