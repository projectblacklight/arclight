# frozen_string_literal: true

require 'ostruct'
require 'active_model'

module Arclight
  #
  # Static information about a given repository identified by a unique `slug`
  class Repository
    include ActiveModel::Model

    attr_accessor :slug, :name, :description, :visit_note, :contact_html, :location_html, :thumbnail_url, :request_types, :collection_count

    def initialize(attributes = {})
      super

      @request_types ||= {}
    end

    # rubocop:disable Rails/OutputSafety
    def contact
      contact_html&.html_safe
    end

    def location
      location_html&.html_safe
    end
    # rubocop:enable Rails/OutputSafety

    def request_config_present?
      request_configs = request_types.values || []
      request_configs.dig(0, 'request_url').present? &&
        request_configs.dig(0, 'request_mappings').present?
    end

    def request_config_present_for_type?(type)
      config = request_config_for_type(type)

      config['request_url'].present? &&
        config['request_mappings'].present?
    end

    def request_config_for_type(type)
      request_types.fetch(type, {})
    end

    def available_request_types
      return [] unless request_types.present?

      request_types.keys
    end

    # Load repository information from a YAML file
    #
    # @param [String] `filename`
    # @return [Hash<Slug,Repository>]
    def self.from_yaml(file)
      repos = {}
      data = YAML.safe_load(File.read(file))
      data.each_key do |slug|
        repos[slug] = new(data[slug].merge(slug: slug))
      end
      repos
    end

    # Mimics ActiveRecord's `all` behavior
    #
    # @return [Array<Repository>]
    def self.all(yaml_file = nil)
      yaml_file = ENV['REPOSITORY_FILE'] || 'config/repositories.yml' if yaml_file.nil?
      from_yaml(yaml_file).values
    end

    # Mimics ActiveRecord dynamic `find_by` behavior for the slug or name
    #
    # @param [String] `slug` or `name`
    # @return [Repository]
    def self.find_by(slug: nil, name: nil, yaml_file: nil)
      if slug
        all(yaml_file).find { |repo| repo.slug == slug }
      elsif name
        all(yaml_file).find { |repo| repo.name == name }
      else
        raise ArgumentError, 'Requires either slug or name parameters to find_by'
      end
    end

    # Mimics ActiveRecord dynamic `find_by!` behavior for the slug or name
    #
    # @param [String] `slug` or `name` -- same as `find_by`
    # @return [Repository]
    # @raise [ActiveRecord::RecordNotFound] if cannot find repository
    def self.find_by!(**kwargs)
      repository = find_by(**kwargs)
      raise ActiveRecord::RecordNotFound if repository.blank?

      repository
    end
  end
end
