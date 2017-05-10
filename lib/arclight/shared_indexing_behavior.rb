# frozen_string_literal: true

module Arclight
  ##
  # A mixin intended to share indexing behavior between
  # the CustomDocument and CustomComponent classes
  module SharedIndexingBehavior
    # TODO: probably should have a proper DateRange class at some point
    def to_year_from_iso8601(date)
      return if date.blank?
      date.split('-').first[0..3].to_i
    end

    # @param [String] `dates` YYYY or YYYY/YYYY formats, including YYYY-MM, YYYY-MM-DD, and YYYYMMDD
    # @return [Array<String>] all of the years between the given years
    # TODO: probably should have a proper DateRange class at some point
    def to_date_range(dates)
      return if dates.blank?
      start_year, end_year = dates.split('/').map { |date| to_year_from_iso8601(date) }

      return [start_year.to_s] if end_year.nil?
      raise "Unsupported date formats: #{dates}" if (end_year - start_year).abs > 2100
      (start_year..end_year).to_a.map(&:to_s)
    end

    # @see http://eadiva.com/2/unitdate/
    # @return [Array<String>] all of the years between the given years
    def formatted_unitdate_for_range
      return if normal_unit_dates.blank?

      all_dates = Array.wrap(normal_unit_dates)
      puts "WARNING: Unsupported multi-date data: #{normal_unit_dates}" if all_dates.length > 1 # rubocop: disable Rails/Output, Metrics/LineLength

      to_date_range(all_dates.first)
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

    def add_digital_content(prefix:, solr_doc:)
      dao = ng_xml.xpath("#{prefix}/dao").to_a
      return if dao.blank?
      field_name = Solrizer.solr_name('digital_objects', :displayable)
      solr_doc[field_name] = digital_objects(dao)
    end

    def digital_objects(objects)
      objects.map do |dao|
        label = dao.attributes['title'].try(:value) || dao.xpath('daodesc/p').try(:text)
        href = (dao.attributes['href'] || dao.attributes['xlink:href']).try(:value)
        Arclight::DigitalObject.new(label: label, href: href).to_json
      end
    end
  end
end
