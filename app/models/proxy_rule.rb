# frozen_string_literal: true

require 'addressable/template'

class ProxyRule < ApplicationRecord
  acts_as_list scope: %i[owner_id owner_type], add_new_at: :bottom
  scope :ordered, -> { order(position: :asc) }

  include ProxyConfigAffectingChanges::ModelExtension

  belongs_to :proxy
  belongs_to :owner, polymorphic: true # FIXME: we should touch the owner here, but it will raise ActiveRecord::StaleObjectError
  belongs_to :metric

  validates :http_method, :pattern, :owner_id, :owner_type, :metric_id, presence: true
  validates :owner_type, length: { maximum: 255 }
  validates :delta, numericality: { :only_integer => true, :greater_than => 0 }

  before_validation :fill_owner

  after_commit on: [:create, :update] do
    IndexProxyRuleWorker.perform_later(id)
  end

  # add only on_destroy callback
  ThinkingSphinx::Callbacks.append(self, {})

  include ThreeScale::Search::Scopes

  self.allowed_sort_columns = %w[proxy_rules.http_method proxy_rules.pattern proxy_rules.last proxy_rules.position metrics.friendly_name]
  self.default_sort_column = :position
  self.default_sort_direction = :asc

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

  def backend_api_owner?
    owner_type == 'BackendApi'
  end

  delegate :account, to: :owner, allow_nil: true

  def proxies
    backend_api_owner? ? owner.proxies : [proxy]
  end

  def scheduled_for_deletion?
    !owner || !account || owner.scheduled_for_deletion?
  end

  def act_as_list_no_update?
    super || scheduled_for_deletion?
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

  def fill_owner
    return true if owner_type?
    self.owner_id = proxy_id
    self.owner_type = 'Proxy'
  end
end
