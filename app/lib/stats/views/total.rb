
module Stats
  module Views
    module Total
      include ::ThreeScale::MethodTracing

      #
      # == Options
      #
      # +:metric+    metric to get the value for
      # +:metric_id+ id of the metric to get the value for
      # +:period+    period over which to get the value
      # +:since+     start of the period
      # +:timezone+  in which timezone to get the value
      #
      # Notes:
      #
      # - If :metric is set, it must be a Metric instance. Otherwise, :metric_id must be
      #   id of the metric to take.
      #
      # - If :period is a symbol, then :since must be specified and set to something
      #   that quacks like Time. Otherwise, :period must be something that quacks like a
      #   range of times (TimeRange is a good candidate).
      #
      # - :timezone, if set, must be a string name of the timezone (for example "Alaska")
      #
      def total(options)
        options = options.symbolize_keys
        options.assert_valid_keys(:metric, :metric_name, :period, :since, :timezone)

        metric = extract_metric(options)

        period = options[:period]
        period = period.to_sym if period.is_a?(String)

        range = nil
        result = case period
                 when :eternity
          range = TimeRange.new(DateTime.parse('2010-01-01'), DateTime.now)
          total_in_eternity(metric)
                 when Symbol
          since = extract_since(options)
          range = TimeRange.new(since, since.end_of(options[:period].to_sym))
          total_in_fixed_period(period, since, metric)
                 when Range
          range = period.to_time_range
          total_in_range(period.to_time_range, metric)
                 else
          raise InvalidParameterError, ":period must be either symbol or time range, not #{options[:period].inspect}"
        end

        result
      end

      add_three_scale_method_tracer :top

      def total_hits(options = {})
        total(options.reverse_merge(:metric => hits_metric))
      end

      private

      def total_in_fixed_period(period, since, metric)
        storage.get(key_for(:stats, source_key, metric, period => since.to_s(:compact))).to_i
      end

      def total_in_eternity(metric)
        storage.get(key_for(:stats, source_key, metric, :eternity)).to_i
      end

      def total_in_range(range, metric)
        # TODO: Optimize when range spans several months.

        if range.month?
          total_in_fixed_period(:month, range.begin, metric)
        else
          range.each(:day).sum do |time|
            total_in_fixed_period(:day, time.beginning_of_day, metric)
          end
        end
      end

      def hits_metric
        source.first.metrics.hits
      end

      add_three_scale_method_tracer :hits_metric
    end
  end
end
