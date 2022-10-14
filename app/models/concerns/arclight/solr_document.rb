# frozen_string_literal: true

module Arclight
  ##
  # Extends Blacklight::Solr::Document to provide Arclight specific behavior
  module SolrDocument
    include Blacklight::Solr::Document

    def repository_config
      return unless repository

      @repository_config ||= Arclight::Repository.find_by(name: repository)
    end

    def collection
      return self if collection?

      SolrDocument.find(normalized_eadid)
    end

    def parents
      @parents ||= Arclight::Parents.from_solr_document(self).as_parents
    end

    def parent_ids
      fetch('parent_ssim', [])
    end

    def parent_labels
      fetch('parent_unittitles_ssm', [])
    end

    def parent_levels
      fetch('parent_levels_ssm', [])
    end

    def parent_document
      self.class.new fetch('parent').fetch('docs', []).first
    end

    def eadid
      fetch('ead_ssi', nil)&.strip
    end

    def normalized_eadid
      Arclight::NormalizedId.new(eadid).to_s
    end

    def unitid
      first('unitid_ssm')
    end

    def repository
      first('repository_ssm')
    end

    def repository_and_unitid
      [repository, unitid].compact.join(': ')
    end

    def collection_name
      first('collection_ssm')
    end

    def collection_unitid
      first('collection_unitid_ssm')
    end

    def extent
      first('extent_ssm')
    end

    def abstract_or_scope
      first('abstract_ssm') || first('scopecontent_ssm')
    end

    def creator
      first('creator_ssm')
    end

    def collection_creator
      first('collection_creator_ssm')
    end

    def online_content?
      first('has_online_content_ssim') == 'true'
    end

    def number_of_children
      first('child_component_count_isim') || 0
    end

    def children?
      number_of_children.positive?
    end

    def reference
      first('ref_ssm')
    end

    def component_level
      first('component_level_isim')
    end

    def level
      first('level_ssm')
    end

    def collection?
      level.parameterize == 'collection'
    end

    def terms
      first('userestrict_ssm')
    end

    # Restrictions for component sidebar
    def parent_restrictions
      first('parent_access_restrict_ssm')
    end

    # Terms for component sidebar
    def parent_terms
      first('parent_access_terms_ssm')
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

    def normalized_title
      first('normalized_title_ssm')
    end

    def normalized_date
      first('normalized_date_ssm')
    end

    # @return [Array<String>] with embedded highlights using <em>...</em>
    def highlights
      highlight_response = response[:highlighting]
      return if highlight_response.blank? ||
                highlight_response[id].blank? ||
                highlight_response[id][:text].blank?

      highlight_response[id][:text].map(&:html_safe)
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
  end
end
