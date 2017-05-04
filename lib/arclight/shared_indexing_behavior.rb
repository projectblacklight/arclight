# frozen_string_literal: true

module Arclight
  ##
  # A mixin intended to share indexing behavior between
  # the CustomDocument and CustomComponent classes
  module SharedIndexingBehavior
    # @see http://eadiva.com/2/unitdate/
    # Currently only handling normal attributes and YYYY or YYYY/YYYY formats
    def formatted_unitdate_for_range
      return if normal_unit_dates.blank?
      normal_unit_date = Array.wrap(normal_unit_dates).first
      start_date, end_date = normal_unit_date.split('/')
      return [start_date] if end_date.blank?
      (start_date..end_date).to_a
    end

    def subjects_array(elements, parent:)
      xpath_elements = elements.map { |el| "local-name()='#{el}'" }.join(' or ')
      subjects = search("//#{parent}/controlaccess/*[#{xpath_elements}]").to_a
      clean_facets_array(subjects.flatten.map(&:text))
    end

    # Return a cleaned array of facets without marc subfields
    #
    # E.g. clean_facets_array(
    #        ['FacetValue1 |z FacetValue2','FacetValue3']
    #      ) => ['FacetValue1 -- FacetValue2', 'FacetValue3']
    def clean_facets_array(facets_array)
      Array(facets_array).map { |text| fix_subfield_demarcators(text) }.compact.uniq
    end

    # Replace MARC style subfield demarcators
    #
    # Usage: fix_subfield_demarcators("Subject 1 |z Sub-Subject 2") => "Subject 1 -- Sub-Subject 2"
    def fix_subfield_demarcators(value)
      value.gsub(/\|\w{1}/, '--')
    end

    # Wrap OM's find_by_xpath for convenience
    def search(path)
      find_by_xpath(path) # rubocop:disable DynamicFindBy
    end

    # If a repository slug is provided via an environment variable `REPOSITORY_ID`,
    # then use that to lookup the name rather than the parsed out name from the EAD
    # @param [String] `repository` the default repository name
    def repository_as_configured(repository)
      slug = ENV['REPOSITORY_ID']
      if slug.present?
        begin
          Arclight::Repository.find_by(slug: slug).name
        rescue => e
          raise "The repository slug '#{slug}' was given but it is not found in the Repository configuration data: #{e}"
        end
      else
        repository
      end
    end
  end
end
