# frozen_string_literal: true

module Stats
  class BackendApi < Base
    include Views::Usage

    def initialize(*sources)
      source = sources.first
      super(source)
      @services = source.services.map(&Stats::Service.method(:new))
    end

    attr_reader :services

    class UsageResults
      def initialize(options)
        @options = options
      end

      attr_reader :options

      def changes
        return {} if options.fetch(:skip_change, true)

        { previous_total: previous_total, change: change }
      end

      def to_h
        {
          total: total,
          values: values
        }.merge(changes)
      end
    end

    class AggregateUsageResults < UsageResults
      def initialize(options, services)
        super(options)
        @results = services.map { |source| source.usage(options) }
      end

      attr_reader :results

      def total
        map_results(:total).sum
      end

      def previous_total
        map_results(:previous_total).sum
      end

      def change
        total.percentage_change_from(previous_total)
      end

      def values
        map_results(:values).transpose.map(&:sum)
      end

      protected

      def map_results(attr)
        results.map { |result| result[attr] }
      end
    end

    class EmptyResult < UsageResults
      def total
        0
      end

      def previous_total
        0
      end

      def change
        0.0
      end

      def values
        []
      end
    end

    def usage(options)
      result = services.any? ? AggregateUsageResults.new(options, services) : EmptyResult.new(options)
      result.to_h.merge(metric_and_period_details(options))
    end

    protected

    def metric_and_period_details(options)
      metric = extract_metric(options.to_h.symbolize_keys)
      metric_name = metric.class.name.underscore.to_sym

      { metric_name => detail(metric), period: period_detail(options) }
    end
  end
end
