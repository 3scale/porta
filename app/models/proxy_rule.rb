# frozen_string_literal: true

require 'addressable/template'

class ProxyRule < ApplicationRecord

  acts_as_list scope: :proxy, add_new_at: :bottom
  scope :ordered, -> { order(position: :asc) }

  belongs_to :proxy, touch: true
  belongs_to :metric

  include ThreeScale::Search::Scopes

  self.allowed_sort_columns = %w[proxy_rules.http_method proxy_rules.pattern proxy_rules.last proxy_rules.position metrics.friendly_name]
  self.default_sort_column = :position
  self.default_sort_direction = :asc

  validates :http_method, :pattern, :proxy, :metric_id, presence: true
  validates :delta, numericality: { :only_integer => true, :greater_than => 0 }

  ALLOWED_HTTP_METHODS = %w[GET POST DELETE PUT PATCH HEAD OPTIONS].freeze

  class PatternParser
    REGEX_LITERAL = /[_\w]+/i
    REGEX_VARIABLE = /\{#{REGEX_LITERAL}\}/

    # pchar         = unreserved | escaped |
    #                 ":" | "@" | "&" | "=" | "+" | "$" | ","
    param = /
      (?:
        [#{URI::REGEXP::PATTERN::UNRESERVED}:@&=+,] # note that $ is in the RFC but is removed for our purpposes
        |
        #{URI::REGEXP::PATTERN::ESCAPED}
        |
        #{REGEX_VARIABLE}
      )*
    /x

    segment = /
      #{param}
      (?:;#{param})*
    /x

    REGEX_PATH = %r{
      /#{segment}(?:/#{segment})* # normal URI path segments like /foo/bar
    }x

    query = /
      (?:
        [#{URI::REGEXP::PATTERN::UNRESERVED}#{URI::REGEXP::PATTERN::RESERVED}]
        |
        #{URI::REGEXP::PATTERN::ESCAPED}
        |
        #{REGEX_LITERAL}=#{REGEX_VARIABLE}
      )*
    /x

    ABSOLUTE_PATH = /\A
      #{REGEX_PATH} # absolute path
      [$]? # optionally forcing to match the end of path
      (?:\?(?:#{query}))? # optionally followed by a query string
    \Z/x

    def initialize
      @pattern = ABSOLUTE_PATH
    end

    attr_reader :pattern

    def =~(other)
      other =~ pattern
    end

    def call(_)
      pattern
    end
  end

  validates :pattern, format: { with: PatternParser.new, allow_blank: true }
  # a valid pattern is: slash alone or a path => maybe a dollar sign => maybe a query string

  validates :pattern, length: { maximum: 255 }
  validates :http_method, inclusion: { in: ALLOWED_HTTP_METHODS }
  validate :non_repeated_parameters
  validate :no_vars_in_keys
  validates :redirect_url, format: URI.regexp(%w[http https]), allow_blank: true, length: { maximum: 10000 }

  def parameters
    Addressable::Template.new(path_pattern).variables
  end

  def querystring_parameters
    query = query_pattern or return {}
    Hash[query.split('&').map { |kv| kv.split('=', 2) }]
  end

  def metric_system_name
    metric.try!(:system_name)
  end

  def path_pattern
    pattern_uri.path
  end

  def query_pattern
    pattern_uri.query
  end

  def pattern_uri
    Addressable::URI.parse(pattern || '')
  rescue Addressable::URI::InvalidURIError
    Addressable::URI.new
  end

  protected

  def querystring_parameter_keys
    query = query_pattern or return []
    query.split('&').flat_map { |kv| kv.split('=').first }
  end

  def non_repeated_parameters
    pattern = path_pattern
    return if pattern.blank?

    duplicated = Addressable::Template.new(pattern).named_captures.values.any? { |captures| captures.size > 1}

    unless duplicated
      params = parameters + querystring_parameter_keys
      duplicated |= params != params.uniq
    end

    errors.add(:pattern, "Can't have repeated variable names") if duplicated
  end

  def no_vars_in_keys
    if querystring_parameters.keys.any?(&PatternParser::REGEX_VARIABLE.method(:match))
      errors.add(:pattern, "Can't use variables as keys in the querystring")
    end
  end

end
