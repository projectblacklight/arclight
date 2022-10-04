# frozen_string_literal: true

module Arclight
  ##
  # Plain ruby class to model serializing/deserializing digital object data
  class DigitalObject
    attr_reader :label, :href

    def initialize(label:, href:)
      @label = label.presence || href
      @href = href
    end

    def to_json(*)
      { label: label, href: href }.to_json
    end

    def self.from_json(json)
      object_data = JSON.parse(json)
      new(label: object_data['label'], href: object_data['href'])
    end

    def ==(other)
      href == other.href && label == other.label
    end
  end
end
