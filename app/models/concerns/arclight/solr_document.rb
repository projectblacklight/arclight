# frozen_string_literal: true

module Arclight
  ##
  # Extends Blacklight::Solr::Document to provide Arclight specific behavior
  module SolrDocument
    extend Blacklight::Solr::Document

    def repository_config
      return unless repository
      @repository_config ||= Arclight::Repository.find_by(name: repository)
    end

    def parent_ids
      fetch('parent_ssm', [])
    end

    def parent_labels
      fetch('parent_unittitles_ssm', [])
    end

    def eadid
      fetch('ead_ssi', nil)
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

    def extent
      first('extent_ssm')
    end

    def abstract_or_scope
      first('abstract_ssm') || first('scopecontent_ssm')
    end

    def creator
      first('creator_ssm')
    end

    def online_content?
      first('has_online_content_ssm') == 'true'
    end

    def number_of_children
      first('child_component_count_isim') || 0
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

    def digital_objects
      digital_objects_field = fetch('digital_objects_ssm', [])
      return [] if digital_objects_field.blank?

      digital_objects_field.map do |object|
        Arclight::DigitalObject.from_json(object)
      end
    end

    def containers
      fetch('containers_ssim', [])
    end

    def normalized_title
      first('normalized_title_ssm')
    end

    def normalized_date
      first('normalized_date_ssm')
    end
  end
end
