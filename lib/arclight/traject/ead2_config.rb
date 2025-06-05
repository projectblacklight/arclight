# frozen_string_literal: true

require 'logger'
require 'traject'
require 'traject/nokogiri_reader'
require 'traject_plus'
require 'traject_plus/macros'
require 'arclight/level_label'
require 'arclight/normalized_id'
require 'arclight/normalized_date'
require 'arclight/normalized_title'
require 'active_model/conversion' ## Needed for Arclight::Repository
require 'active_support/core_ext/array/wrap'
require 'arclight/digital_object'
require 'arclight/year_range'
require 'arclight/repository'
require 'arclight/traject/nokogiri_namespaceless_reader'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

NAME_ELEMENTS = %w[corpname famname name persname].freeze

SEARCHABLE_NOTES_FIELDS = %w[
  accessrestrict
  accruals
  altformavail
  appraisal
  arrangement
  bibliography
  bioghist
  custodhist
  fileplan
  note
  odd
  originalsloc
  otherfindaid
  phystech
  prefercite
  processinfo
  relatedmaterial
  scopecontent
  separatedmaterial
  userestrict
].freeze

DID_SEARCHABLE_NOTES_FIELDS = %w[
  abstract
  materialspec
  physloc
  note
].freeze

settings do
  provide 'component_traject_config', File.join(__dir__, 'ead2_component_config.rb')
  provide 'id_normalizer', 'Arclight::NormalizedId'
  provide 'date_normalizer', 'Arclight::NormalizedDate'
  provide 'title_normalizer', 'Arclight::NormalizedTitle'
  provide 'reader_class_name', 'Arclight::Traject::NokogiriNamespacelessReader'
  provide 'solr_writer.commit_on_close', 'true'
  provide 'repository', ENV.fetch('REPOSITORY_ID', nil)
  provide 'logger', Logger.new($stderr)
end

each_record do |_record, context|
  next unless settings['repository']

  context.clipboard[:repository] = Arclight::Repository.find_by(
    slug: settings['repository']
  ).name
end

# ==================
# Top level document
#
# NOTE: All fields should be stored in Solr
# ==================

to_field 'id' do |record, accumulator|
  id = record.at_xpath('/ead/eadheader/eadid')&.text
  unitid = record.at_xpath('/ead/archdesc/did/unitid')&.text
  title = record.at_xpath('/ead/archdesc/did/unittitle')&.text
  repository = settings['repository']
  accumulator << settings['id_normalizer'].constantize.new(id, unitid: unitid, title: title, repository: repository).to_s
end

to_field 'title_filing_ssi', extract_xpath('/ead/eadheader/filedesc/titlestmt/titleproper[@type="filing"]')
to_field 'title_ssm', extract_xpath('/ead/archdesc/did/unittitle')
to_field 'title_tesim', extract_xpath('/ead/archdesc/did/unittitle')
to_field 'ead_ssi', extract_xpath('/ead/eadheader/eadid')

to_field 'unitdate_ssm', extract_xpath('/ead/archdesc/did/unitdate')
to_field 'unitdate_bulk_ssim', extract_xpath('/ead/archdesc/did/unitdate[@type="bulk"]')
to_field 'unitdate_inclusive_ssm', extract_xpath('/ead/archdesc/did/unitdate[@type="inclusive"]')
to_field 'unitdate_other_ssim', extract_xpath('/ead/archdesc/did/unitdate[not(@type)]')

# All top-level docs treated as 'collection' for routing / display purposes
to_field 'level_ssm' do |_record, accumulator|
  accumulator << 'collection'
end

# Keep the original top-level archdesc/@level for Level facet in addition to 'Collection'
to_field 'level_ssim' do |record, accumulator|
  level = record.at_xpath('/ead/archdesc').attribute('level')&.value
  other_level = record.at_xpath('/ead/archdesc').attribute('otherlevel')&.value

  accumulator << Arclight::LevelLabel.new(level, other_level).to_s
  accumulator << 'Collection' unless level == 'collection'
end

to_field 'unitid_ssm', extract_xpath('/ead/archdesc/did/unitid')
to_field 'unitid_tesim', extract_xpath('/ead/archdesc/did/unitid')

to_field 'normalized_date_ssm' do |_record, accumulator, context|
  accumulator << settings['date_normalizer'].constantize.new(
    context.output_hash['unitdate_inclusive_ssm'],
    context.output_hash['unitdate_bulk_ssim'],
    context.output_hash['unitdate_other_ssim']
  ).to_s
end

to_field 'normalized_title_ssm' do |_record, accumulator, context|
  title = context.output_hash['title_ssm']&.first
  date = context.output_hash['normalized_date_ssm']&.first
  accumulator << settings['title_normalizer'].constantize.new(title, date).to_s
end

to_field 'collection_title_tesim' do |_record, accumulator, context|
  accumulator.concat context.output_hash.fetch('normalized_title_ssm', [])
end

to_field 'collection_ssim' do |_record, accumulator, context|
  accumulator.concat context.output_hash.fetch('normalized_title_ssm', [])
end

to_field 'repository_ssm' do |_record, accumulator, context|
  accumulator << context.clipboard[:repository]
end

to_field 'repository_ssim' do |_record, accumulator, context|
  accumulator << context.clipboard[:repository]
end

to_field 'geogname_ssm', extract_xpath('/ead/archdesc/controlaccess/geogname')
to_field 'geogname_ssim', extract_xpath('/ead/archdesc/controlaccess/geogname')

to_field 'creator_ssm', extract_xpath('/ead/archdesc/did/origination')
to_field 'creator_ssim', extract_xpath('/ead/archdesc/did/origination')
to_field 'creator_sort' do |record, accumulator|
  accumulator << record.xpath('/ead/archdesc/did/origination').map { |c| c.text.strip }.join(', ')
end

to_field 'creator_persname_ssim', extract_xpath('/ead/archdesc/did/origination/persname')
to_field 'creator_corpname_ssim', extract_xpath('/ead/archdesc/did/origination/corpname')
to_field 'creator_famname_ssim', extract_xpath('/ead/archdesc/did/origination/famname')

to_field 'creators_ssim' do |_record, accumulator, context|
  accumulator.concat context.output_hash['creator_persname_ssim'] if context.output_hash['creator_persname_ssim']
  accumulator.concat context.output_hash['creator_corpname_ssim'] if context.output_hash['creator_corpname_ssim']
  accumulator.concat context.output_hash['creator_famname_ssim'] if context.output_hash['creator_famname_ssim']
end

to_field 'places_ssim', extract_xpath('/ead/archdesc/controlaccess/geogname')

to_field 'access_terms_ssm', extract_xpath('/ead/archdesc/userestrict/*[local-name()!="head"]')

to_field 'acqinfo_ssim', extract_xpath('/ead/archdesc/acqinfo/*[local-name()!="head"]')
to_field 'acqinfo_ssim', extract_xpath('/ead/archdesc/descgrp/acqinfo/*[local-name()!="head"]')

to_field 'access_subjects_ssim', extract_xpath('/ead/archdesc/controlaccess', to_text: false) do |_record, accumulator|
  accumulator.map! do |element|
    %w[subject function occupation genreform].map do |selector|
      element.xpath(".//#{selector}").map(&:text)
    end
  end.flatten!
end

to_field 'access_subjects_ssm' do |_record, accumulator, context|
  accumulator.concat Array.wrap(context.output_hash['access_subjects_ssim'])
end

to_field 'has_online_content_ssim', extract_xpath('.//dao') do |_record, accumulator|
  accumulator.replace([accumulator.any?])
end

to_field 'digital_objects_ssm', extract_xpath('/ead/archdesc/did/dao|/ead/archdesc/dao', to_text: false) do |_record, accumulator|
  accumulator.map! do |dao|
    label = dao.attributes['title']&.value ||
            dao.xpath('daodesc/p')&.text
    href = (dao.attributes['href'] || dao.attributes['xlink:href'])&.value
    Arclight::DigitalObject.new(label: label, href: href).to_json
  end
end

# This accumulates direct text from a physdesc, ignoring child elements handled elsewhere
to_field 'physdesc_tesim', extract_xpath('/ead/archdesc/did/physdesc', to_text: false) do |_record, accumulator|
  accumulator.map! do |element|
    physdesc = []
    element.children.map do |child|
      next if child.instance_of?(Nokogiri::XML::Element)

      physdesc << child.text&.strip unless child.text&.strip&.empty?
    end.flatten
    physdesc.join(' ') unless physdesc.empty?
  end
end

to_field 'extent_ssm' do |record, accumulator|
  physdescs = record.xpath('/ead/archdesc/did/physdesc')
  extents_per_physdesc = physdescs.map do |physdesc|
    extents = physdesc.xpath('./extent').map { |e| e.text.strip }
    # Join extents within the same physdesc with an empty string
    extents.join(' ') unless extents.empty?
  end

  # Add each physdesc separately to the accumulator
  accumulator.concat(extents_per_physdesc)
end

to_field 'extent_tesim' do |_record, accumulator, context|
  accumulator.concat context.output_hash['extent_ssm'] || []
end

to_field 'physfacet_tesim', extract_xpath('/ead/archdesc/did/physdesc/physfacet')
to_field 'dimensions_tesim', extract_xpath('/ead/archdesc/did/physdesc/dimensions')

to_field 'genreform_ssim', extract_xpath('/ead/archdesc/controlaccess/genreform')

to_field 'date_range_isim', extract_xpath('/ead/archdesc/did/unitdate/@normal', to_text: false) do |_record, accumulator|
  range = Arclight::YearRange.new
  next range.years if accumulator.blank?

  ranges = accumulator.map(&:to_s)
  range << range.parse_ranges(ranges)
  accumulator.replace range.years
end

to_field 'indexes_html_tesm', extract_xpath('/ead/archdesc/index', to_text: false)
to_field 'indexes_tesim', extract_xpath('/ead/archdesc/index')

SEARCHABLE_NOTES_FIELDS.map do |selector|
  to_field "#{selector}_html_tesm", extract_xpath("/ead/archdesc/#{selector}/*[local-name()!='head']", to_text: false) do |_record, accumulator|
    accumulator.map!(&:to_html)
  end
  to_field "#{selector}_heading_ssm", extract_xpath("/ead/archdesc/#{selector}/head") unless selector == 'prefercite'
  to_field "#{selector}_tesim", extract_xpath("/ead/archdesc/#{selector}/*[local-name()!='head']")
end

DID_SEARCHABLE_NOTES_FIELDS.map do |selector|
  to_field "#{selector}_html_tesm", extract_xpath("/ead/archdesc/did/#{selector}", to_text: false)
  to_field "#{selector}_tesim", extract_xpath("/ead/archdesc/did/#{selector}")
end

NAME_ELEMENTS.map do |selector|
  to_field 'names_coll_ssim', extract_xpath("/ead/archdesc/controlaccess/#{selector}")
  to_field 'names_ssim', extract_xpath("//#{selector}"), unique
  to_field "#{selector}_ssim", extract_xpath("//#{selector}"), unique
end

to_field 'language_ssim', extract_xpath('/ead/archdesc/did/langmaterial')

to_field 'descrules_ssm', extract_xpath('/ead/eadheader/profiledesc/descrules')

# count all descendant components from the top-level
to_field 'total_component_count_is', first_only do |record, accumulator|
  accumulator << record.xpath('//c|//c01|//c02|//c03|//c04|//c05|//c06|//c07|//c08|//c09|//c10|//c11|//c12').count
end

# count all digital objects from the top-level
to_field 'online_item_count_is', first_only do |record, accumulator|
  accumulator << record.xpath('//dao').count
end

to_field 'component_level_isim' do |_record, accumulator, _context|
  accumulator << 0
end

to_field 'sort_isi' do |_record, accumulator, _context|
  accumulator << 0
end

# =============================
# Each component child document
# <c> <c01> <c12>
# =============================

to_field 'components' do |record, accumulator, context|
  child_components = record.xpath("/ead/archdesc/dsc/c|#{('/ead/archdesc/dsc/c01'..'/ead/archdesc/dsc/c12').to_a.join('|')}")
  next unless child_components.any?

  counter = Class.new do
    def increment
      @counter ||= 0
      @counter += 1
    end
  end.new

  component_indexer = Traject::Indexer::NokogiriIndexer.new.tap do |i|
    i.settings do
      provide :parent, context
      provide :root, context
      provide :counter, counter
      provide :depth, 1
      provide :logger, context.settings[:logger]
      provide :component_traject_config, context.settings[:component_traject_config]
    end

    i.load_config_file(context.settings[:component_traject_config])
  end

  child_components.each do |child_component|
    output = component_indexer.map_record(child_component)
    accumulator << output if output.keys.any?
  end
end
