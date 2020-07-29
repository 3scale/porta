# frozen_string_literal: true

class UriShortener
  def self.call(uri)
    new(uri).call
  end

  def initialize(uri)
    @uri = URI.parse(uri)
  rescue URI::InvalidURIError
  end

  attr_reader :uri

  def call
    return unless uri
    labels = uri.host.split('.')
    uri.host = labels.map(&UriLabelShortner.method(:call)).join('.')
    uri
  end

  class UriLabelShortner
    def self.call(label)
      new(label).call
    end

    def initialize(label)
      @label = label
    end

    attr_reader :label
    delegate :size, to: :label

    MAX_LABEL_SIZE = UriValidator::UriThreeScaleComplianceChecker::MAX_LABEL_SIZE
    HASH_SIZE = 7
    KEEP_SIZE = (MAX_LABEL_SIZE - HASH_SIZE - 1).freeze

    def call
      return label if size <= MAX_LABEL_SIZE
      [*label.slice(0, KEEP_SIZE).split('-'), hash].join('-')
    end

    def hash
      Digest::SHA1.hexdigest(label).slice(0, HASH_SIZE)
    end
  end
end
