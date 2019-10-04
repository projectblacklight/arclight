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
          <dsc>
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
          </dsc>
        </archdesc>
      </ead>
    XML
  end

  it 'returns the absolute xpath of node passed in (adding indexes to all the c nodes)' do
    expect(described_class.new(components[0]).absolute_xpath).to eq 'document/ead/archdesc/dsc/c0'
    expect(described_class.new(components[1]).absolute_xpath).to eq 'document/ead/archdesc/dsc/c0/c0'
    expect(described_class.new(components[2]).absolute_xpath).to eq 'document/ead/archdesc/dsc/c1'
    expect(described_class.new(components[3]).absolute_xpath).to eq 'document/ead/archdesc/dsc/c1/c0'
    expect(described_class.new(components[4]).absolute_xpath).to eq 'document/ead/archdesc/dsc/c1/c1'
  end

  it 'hashes the absolute_xpath & prepends al_' do
    expect(described_class.new(components[0]).to_hexdigest).to eq 'al_9c4e84c284385184b7e3548ebe2a81a9df522a67'
    expect(described_class.new(components[1]).to_hexdigest).to eq 'al_73760c5f85d3691b9f537a5ca3d887825e6e0ee9'
    expect(described_class.new(components[2]).to_hexdigest).to eq 'al_44c3b0a0ba891df68aa056f9d3e3fcf23f64ad4e'
    expect(described_class.new(components[3]).to_hexdigest).to eq 'al_75fdc26f3f0a5fd30e157dbd523885a4eda7ecb3'
    expect(described_class.new(components[4]).to_hexdigest).to eq 'al_72636263da05d832fb4a05c90c2b2c79480af70e'
  end

  it 'allows the hashing algorithm to be configured' do
    hash_algorithm = described_class.hash_algorithm
    described_class.hash_algorithm = Digest::SHA256
    expect(described_class.new(components[0]).to_hexdigest).to eq 'al_4b884bc407a22e7e6a41867ef4987b7c49f81c641fe0c4d1f92009a5e4b963a9'
    described_class.hash_algorithm = hash_algorithm
  end
end
