# frozen_string_literal: true

module ThreeScale::Middleware
  class Cors < Rack::Cors
    def initialize(app, opts = {}, &block)
      super(app, opts) { set_config }
      set_excludes

      if block_given? # rubocop:disable Style/GuardClause why: keep copy from superclass
        if block.arity == 1
          block.call(self) # rubocop:disable Performance/RedundantBlockCall why: keep copy from superclass
        else
          instance_eval(&block)
        end
      end
    end

    def call(env)
      return @app.call(env) if excluded?(env)

      super
    end

    private

    def config
      Rails.configuration.three_scale.cors
    end

    def set_config # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
      rules = config.allow.presence || []

      rules.map(&:symbolize_keys).each do |rule|
        origins = rule[:origins].presence || '*'
        resources = rule[:resources].presence || '*'
        methods = rule[:methods].presence || :get

        allow do
          self.origins origins
          [*resources].each do |resource|
            self.resource resource, headers: rule[:headers].presence, methods: methods, credentials: rule[:credentials].present?, max_age: rule[:max_age].presence, vary: rule[:vary], expose: rule[:expose].presence
          end
        end
      end
    end

    def set_excludes
      rules = config.exclude.presence || []

      @excludes = rules.map do |rule|
        ExcludeMatcher.for(rule.symbolize_keys)
      end
    end

    def excluded?(env)
      @excludes.any? { |matcher| matcher.matches?(env) }
    end
  end

  module ExcludeMatcher
    class << self
      def matchers
        @matchers ||= Set.new
      end

      def add_matchers(*matcher_classes)
        matchers.merge matcher_classes.flatten
      end

      def for(rule)
        matcher = matchers.detect { |klass| klass.supports?(rule) }

        raise ThreeScale::ConfigurationError, "Unsupported exclude specification: #{rule}" unless matcher

        matcher.new(rule)
      end
    end

    class PathRegexpMatcher
      attr_reader :regexp

      def initialize(rule)
        regexp = rule[:path_regexp]
        @regexp = regexp.is_a?(Regexp) ? regexp : /#{regexp}/
      end

      def matches?(env)
        regexp.match? env["PATH_INFO"]
      end

      def self.supports?(rule)
        rule[:path_regexp].present?
      end
    end

    class PathPrefixMatcher < PathRegexpMatcher
      def initialize(rule)
        path = rule[:path_prefix]
        segment_end_check = path.end_with?("/") ? "" : "(?:/|$)"
        super({path_regexp: /^#{path}#{segment_end_check}/})
      end

      def self.supports?(rule)
        rule[:path_prefix].present?
      end
    end

    add_matchers PathPrefixMatcher, PathRegexpMatcher
  end
end
