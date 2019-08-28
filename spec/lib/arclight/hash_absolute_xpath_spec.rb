# frozen_string_literal: true

require 'spec_helper'
require 'arclight/hash_absolute_xpath'

RSpec.describe Arclight::HashAbsoluteXpath do
  let(:components) { xml.xpath('//xmlns:c') }

  let(:xml) { Nokogiri::XML.parse(raw_xml) }

  let(:raw_xml) do
    <<-XML
      <ead
        xmlns="urn:isbn:1-931666-22-9"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd"
      >
        <archdesc>
          <c>
            <did><unittitle>C0</unittitle></did>
            <c>
              <did><unittitle>C0.0</unittitle></did>
            </c>
          </c>
          <c>
            <did><unittitle>C1</unittitle></did>
            <c>
              <did><unittitle>C1.0</unittitle></did>
            </c>
            <c>
              <did><unittitle>C1.1</unittitle></did>
            </c>
          </c>
        </archdesc>
      </ead>
    XML
  end

  it 'returns the absolute xpath of node passed in (adding indexes to all the c nodes)' do
    expect(described_class.new(components[0]).absolute_xpath).to eq 'document/ead/archdesc/c0'
    expect(described_class.new(components[1]).absolute_xpath).to eq 'document/ead/archdesc/c0/c0'
    expect(described_class.new(components[2]).absolute_xpath).to eq 'document/ead/archdesc/c1'
    expect(described_class.new(components[3]).absolute_xpath).to eq 'document/ead/archdesc/c1/c0'
    expect(described_class.new(components[4]).absolute_xpath).to eq 'document/ead/archdesc/c1/c1'
  end

  it 'hashes the absolute_xpath' do
    expect(described_class.new(components[0]).to_hexdigest).to eq 'c015cba710557ac75e1c9b4da33e37fbdee41e82'
    expect(described_class.new(components[1]).to_hexdigest).to eq '0e6141f0e5d704f223e254e26a62c954643f5553'
    expect(described_class.new(components[2]).to_hexdigest).to eq '24494999c8c5a300dabdcd74f0885f1f380a71f3'
    expect(described_class.new(components[3]).to_hexdigest).to eq '76229094a02f4644b05317e51ecaa5dfc950d811'
    expect(described_class.new(components[4]).to_hexdigest).to eq '20fb448f390a0e3a5da9f2506c782a62e6264fc9'
  end

  it 'allows the hashing algorithm to be configured' do
    hash_algorithm = described_class.hash_algorithm
    described_class.hash_algorithm = Digest::SHA256
    expect(described_class.new(components[0]).to_hexdigest).to eq '0b77f8ad4db958f29236f78bd367f466c82b45800ffae72a1cec91742fa37a59'
    described_class.hash_algorithm = hash_algorithm
  end
end
