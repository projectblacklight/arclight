require 'traject'
require 'traject/nokogiri_reader'
require 'traject_plus'
require 'traject_plus/macros'
require 'arclight/normalized_date'
require 'arclight/normalized_title'
require 'active_support/core_ext/array/wrap'

extend TrajectPlus::Macros

settings do
  provide "nokogiri.namespaces",  {
    "xmlns" => "urn:isbn:1-931666-22-9",
  }
  provide "solr_writer.commit_on_close", "true"
end

# Top level
to_field 'id', extract_xpath("//xmlns:eadid"), strip, gsub('.', '-')
to_field 'title_ssm', extract_xpath("//xmlns:archdesc/xmlns:did/xmlns:unittitle")
to_field 'title_teim', extract_xpath("//xmlns:archdesc/xmlns:did/xmlns:unittitle")
to_field 'ead_ssi' do |record, accumulator, context|
  accumulator << context.output_hash['id'].first
end

to_field 'unitdate_bulk_ssim', extract_xpath('//xmlns:archdesc/xmlns:did/xmlns:unitdate[@type="bulk"]')
to_field 'unitdate_inclusive_ssim', extract_xpath('//xmlns:archdesc/xmlns:did/xmlns:unitdate[@type="inclusive"]')
to_field 'unitdate_other_ssim', extract_xpath('//xmlns:archdesc/xmlns:did/xmlns:unitdate[not(@type)]')

to_field 'normalized_title_ssm' do |record, accumulator, context|
  dates = Arclight::NormalizedDate.new(context.output_hash['unitdate_inclusive_ssim'], context.output_hash['unitdate_bulk_ssim'], context.output_hash['unitdate_other_ssim']).to_s
  title = context.output_hash['title_ssm'].first
  accumulator << Arclight::NormalizedTitle.new(title, dates).to_s
end

# Each component child document
# <c> <c01> <c12>
compose 'components', ->(record, accumulator, context) { accumulator.concat record.xpath("//*[is_component(.)]", NokogiriXpathExtensions.new())} do
  to_field 'id' do |record, accumulator, context|
    accumulator << [
      context.clipboard[:parent].output_hash['id'],
      record.attribute('id')&.value&.strip&.gsub('.', '-')
    ].join('')
  end

  to_field 'ead_ssi' do |record, accumulator, context|
    accumulator << context.output_hash['id'].first
  end

  to_field 'title_ssm', extract_xpath("./xmlns:did/xmlns:unittitle")
  to_field 'title_teim', extract_xpath("./xmlns:did/xmlns:unittitle")

  to_field 'unitdate_bulk_ssim', extract_xpath('./xmlns:did/xmlns:unitdate[@type="bulk"]')
  to_field 'unitdate_inclusive_ssim', extract_xpath('./xmlns:did/xmlns:unitdate[@type="inclusive"]')
  to_field 'unitdate_other_ssim', extract_xpath('./xmlns:did/xmlns:unitdate[not(@type)]')

  to_field 'normalized_title_ssm' do |record, accumulator, context|
    dates = Arclight::NormalizedDate.new(context.output_hash['unitdate_inclusive_ssim'], context.output_hash['unitdate_bulk_ssim'], context.output_hash['unitdate_other_ssim']).to_s
    title = context.output_hash['title_ssm'].first
    accumulator << Arclight::NormalizedTitle.new(title, dates).to_s
  end

  to_field 'component_level_isim', literal(0)
end


each_record do |_record, context|
  context.output_hash['components'] &&= context.output_hash['components'].select { |c| c.keys.any? }
end

class NokogiriXpathExtensions
  def is_component node_set
    node_set.find_all do |node|
      component_elements = (1..12).map { |i| "c#{'%02d' % i}"}
      component_elements.push 'c'
      component_elements.include? node.name
    end
  end
end
