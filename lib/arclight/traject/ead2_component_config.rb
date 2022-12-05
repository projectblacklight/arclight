# frozen_string_literal: true

require 'logger'
require 'traject'
require 'traject/nokogiri_reader'
require 'traject_plus'
require 'traject_plus/macros'
require 'arclight/level_label'
require 'arclight/normalized_date'
require 'arclight/normalized_title'
require 'active_model/conversion' ## Needed for Arclight::Repository
require 'active_support/core_ext/array/wrap'
require 'arclight/digital_object'
require 'arclight/year_range'
require 'arclight/missing_id_strategy'
require 'arclight/traject/nokogiri_namespaceless_reader'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

settings do
  # provide 'root' # the root EAD collection indexing context
  # provide 'parent' # the immediate parent component (or collection) indexing context
  # provide 'counter' # a global component counter to provide a global sort order for nested components
  # provide 'depth' # the current nesting depth of the component
  provide 'component_traject_config', __FILE__
  provide 'date_normalizer', 'Arclight::NormalizedDate'
  provide 'title_normalizer', 'Arclight::NormalizedTitle'
  provide 'reader_class_name', 'Arclight::Traject::NokogiriNamespacelessReader'
  provide 'logger', Logger.new($stderr)
end

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
].freeze

# ==================
# Component elements
#
# NOTE: All fields should be stored in Solr
# ==================
to_field 'ref_ssi' do |record, accumulator, _context|
  accumulator << if record.attribute('id').blank?
                   strategy = Arclight::MissingIdStrategy.selected
                   hexdigest = strategy.new(record).to_hexdigest
                   parent_id = settings[:parent].output_hash['id'].first
                   root_id = settings[:root].output_hash['id'].first
                   logger.warn('MISSING ID WARNING') do
                     [
                       "A component in #{parent_id} did not have an ID so one was minted using the #{strategy} strategy.",
                       "The ID of this document will be #{root_id}#{hexdigest}."
                     ].join(' ')
                   end
                   record['id'] = hexdigest
                   hexdigest
                 else
                   record.attribute('id')&.value&.strip&.gsub('.', '-')
                 end
end
to_field 'ref_ssm' do |_record, accumulator, context|
  accumulator.concat context.output_hash['ref_ssi']
end

to_field 'id' do |_record, accumulator, context|
  accumulator << [
    settings[:root].output_hash['id'],
    context.output_hash['ref_ssi']
  ].join
end

to_field 'title_filing_ssi', extract_xpath('./did/unittitle'), first_only
to_field 'title_ssm', extract_xpath('./did/unittitle')
to_field 'title_tesim', extract_xpath('./did/unittitle')

to_field 'unitdate_bulk_ssim', extract_xpath('./did/unitdate[@type="bulk"]')
to_field 'unitdate_inclusive_ssm', extract_xpath('./did/unitdate[@type="inclusive"]')
to_field 'unitdate_other_ssim', extract_xpath('./did/unitdate[not(@type)]')

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

to_field 'component_level_isim' do |_record, accumulator|
  accumulator << (settings[:depth] || 1)
end

to_field 'parent_ssim' do |_record, accumulator, _context|
  accumulator.concat(settings[:parent].output_hash['parent_ssim'] || [])
  accumulator.concat settings[:parent].output_hash['ref_ssi'] || settings[:parent].output_hash['id']
end

to_field 'parent_ssi' do |_record, accumulator, _context|
  accumulator.concat settings[:parent].output_hash['ref_ssi'] || settings[:parent].output_hash['id']
end

to_field 'parent_unittitles_ssm' do |_rec, accumulator, _context|
  accumulator.concat(settings[:parent].output_hash['parent_unittitles_ssm'] || [])
  accumulator.concat settings[:parent].output_hash['normalized_title_ssm'] || []
end

to_field 'parent_unittitles_tesim' do |_record, accumulator, context|
  accumulator.concat context.output_hash['parent_unittitles_ssm']
end

to_field 'parent_levels_ssm' do |_record, accumulator, _context|
  ## Top level document
  accumulator.concat settings[:parent].output_hash['parent_levels_ssm'] || []
  accumulator.concat settings[:parent].output_hash['level_ssm'] || []
end

to_field 'unitid_ssm', extract_xpath('./did/unitid')
to_field 'repository_ssim' do |_record, accumulator, _context|
  accumulator << settings[:root].clipboard[:repository]
end

to_field 'collection_ssim' do |_record, accumulator, _context|
  accumulator.concat settings[:root].output_hash['normalized_title_ssm']
end

to_field 'extent_ssm', extract_xpath('./did/physdesc/extent')
to_field 'extent_tesim', extract_xpath('./did/physdesc/extent')

to_field 'creator_ssm', extract_xpath('./did/origination')
to_field 'creator_ssim', extract_xpath('./did/origination')
to_field 'creators_ssim', extract_xpath('./did/origination')
to_field 'creator_sort' do |record, accumulator|
  accumulator << record.xpath('./did/origination').map(&:text).join(', ')
end
to_field 'has_online_content_ssim', extract_xpath('.//dao') do |_record, accumulator|
  accumulator.replace([accumulator.any?])
end
to_field 'child_component_count_isi' do |record, accumulator|
  accumulator << record.xpath('c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12').count
end

to_field 'ref_ssm' do |record, accumulator|
  accumulator << record.attribute('id')
end

to_field 'level_ssm' do |record, accumulator|
  level = record.attribute('level')&.value
  other_level = record.attribute('otherlevel')&.value
  accumulator << Arclight::LevelLabel.new(level, other_level).to_s
end

to_field 'level_ssim' do |_record, accumulator, context|
  next unless context.output_hash['level_ssm']

  accumulator.concat context.output_hash['level_ssm']&.map(&:capitalize)
end

to_field 'sort_isi' do |_record, accumulator, _context|
  accumulator.replace([settings[:counter].increment])
end

# Get the <accessrestrict> from the closest ancestor that has one (includes top-level)
to_field 'parent_access_restrict_tesm' do |record, accumulator|
  accumulator.concat Array
    .wrap(record.xpath('(./ancestor::*/accessrestrict)[last()]/*[local-name()!="head"]')
    .map(&:text))
end

# Get the <userestrict> from self OR the closest ancestor that has one (includes top-level)
to_field 'parent_access_terms_tesm' do |record, accumulator|
  accumulator.concat Array
    .wrap(record.xpath('(./ancestor-or-self::*/userestrict)[last()]/*[local-name()!="head"]')
    .map(&:text))
end

to_field 'digital_objects_ssm', extract_xpath('./dao|./did/dao', to_text: false) do |_record, accumulator|
  accumulator.map! do |dao|
    label = dao.attributes['title']&.value ||
            dao.xpath('daodesc/p')&.text
    href = (dao.attributes['href'] || dao.attributes['xlink:href'])&.value
    Arclight::DigitalObject.new(label: label, href: href).to_json
  end
end

to_field 'date_range_ssim', extract_xpath('./did/unitdate/@normal', to_text: false) do |_record, accumulator|
  range = Arclight::YearRange.new
  next range.years if accumulator.blank?

  ranges = accumulator.map(&:to_s)
  range << range.parse_ranges(ranges)
  accumulator.replace range.years
end

NAME_ELEMENTS.map do |selector|
  to_field 'names_ssim', extract_xpath("./controlaccess/#{selector}"), unique
  to_field "#{selector}_ssim", extract_xpath(".//#{selector}")
end

to_field 'geogname_ssim', extract_xpath('./controlaccess/geogname')
to_field 'geogname_ssm', extract_xpath('./controlaccess/geogname')
to_field 'places_ssim', extract_xpath('./controlaccess/geogname')

to_field 'access_subjects_ssim', extract_xpath('./controlaccess', to_text: false) do |_record, accumulator|
  accumulator.map! do |element|
    %w[subject function occupation genreform].map do |selector|
      element.xpath(".//#{selector}").map(&:text)
    end
  end.flatten!
end

to_field 'access_subjects_ssm' do |_record, accumulator, context|
  accumulator.concat(context.output_hash.fetch('access_subjects_ssim', []))
end

to_field 'acqinfo_ssim', extract_xpath('/ead/archdesc/acqinfo/*[local-name()!="head"]')
to_field 'acqinfo_ssim', extract_xpath('/ead/archdesc/descgrp/acqinfo/*[local-name()!="head"]')
to_field 'acqinfo_ssim', extract_xpath('./acqinfo/*[local-name()!="head"]')
to_field 'acqinfo_ssim', extract_xpath('./descgrp/acqinfo/*[local-name()!="head"]')

to_field 'language_ssim', extract_xpath('./did/langmaterial')
to_field 'containers_ssim' do |record, accumulator|
  record.xpath('./did/container').each do |node|
    accumulator << [node.attribute('type'), node.text].join(' ').strip
  end
end

SEARCHABLE_NOTES_FIELDS.map do |selector|
  to_field "#{selector}_html_tesm", extract_xpath("./#{selector}/*[local-name()!='head']", to_text: false)
  to_field "#{selector}_heading_ssm", extract_xpath("./#{selector}/head")
  to_field "#{selector}_tesim", extract_xpath("./#{selector}/*[local-name()!='head']")
end
DID_SEARCHABLE_NOTES_FIELDS.map do |selector|
  to_field "#{selector}_html_tesm", extract_xpath("./did/#{selector}", to_text: false)
end
to_field 'did_note_ssm', extract_xpath('./did/note')

# =============================
# Each component child document
# <c> <c01> <c12>
# =============================

to_field 'components' do |record, accumulator, context|
  child_components = record.xpath('c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12')
  component_indexer = Traject::Indexer::NokogiriIndexer.new.tap do |i|
    i.settings do
      provide :parent, context
      provide :root, context.settings[:root]
      provide :counter, context.settings[:counter]
      provide :depth, context.settings[:depth].to_i + 1
      provide :component_traject_config, context.settings[:component_traject_config]
    end

    i.load_config_file(context.settings[:component_traject_config])
  end

  child_components.each do |child_component|
    output = component_indexer.map_record(child_component)
    accumulator << output if output.keys.any?
  end
end
