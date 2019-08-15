require 'traject'
require 'traject/nokogiri_reader'
require 'traject_plus'
require 'traject_plus/macros'

extend TrajectPlus::Macros

settings do
  provide "nokogiri.namespaces",  {
    "xmlns" => "urn:isbn:1-931666-22-9",
  }
end

# Top level 
to_field 'id', extract_xpath("//xmlns:eadid"), strip, gsub('.', '-')
to_field 'title_ssm', extract_xpath("//xmlns:archdesc/xmlns:did/xmlns:unittitle")
to_field 'title_teim', extract_xpath("//xmlns:archdesc/xmlns:did/xmlns:unittitle")

# Each component child document
# <c> <c01> <c12>
compose 'components', ->(record, accumulator, context) { accumulator.concat record.xpath("//*[is_component(.)]", NokogiriXpathExtensions.new())} do
  to_field 'id' do |record, accumulator, context|
    accumulator << [
      context.clipboard[:parent].output_hash['id'],
      record.attribute('id')&.value
    ].join('')
  end
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
