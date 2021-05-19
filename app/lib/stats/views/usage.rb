
module Stats
  module Views
    module Usage

      GRANULARITIES = {:year  => :month,
                       :month => :day,
                       :week  => 6.hours,
                       :day   => :hour}.with_indifferent_access

      ALLOWED_GRANULARITIES = GRANULARITIES.values

      ALLOWED_TIME_RANGES = {:month  => 10.years,
                             :day    => 1.year,
                             6.hours => 6.months, # 6.hours looks unused, but since it's a valid granularity we need to check it as well
                             :hour   => 90.days}.with_indifferent_access

      def usage(options)
        range, granularity, metric = extract_range_and_granularity_and_metric(options)

        data = usage_values_in_range(range, granularity, metric) # metric can be a response_code

        total = data.sum

        result = {
                metric.class.name.underscore.to_sym => detail(metric),
                :period => period_detail(options),
                :total       => total,
                :values      => data
              }

        unless @cinstance.nil?
          result[:application] = {
            :id    => @cinstance.id,
            :name  => @cinstance.name,
            :state => @cinstance.state,
            :description => @cinstance.description,
            :plan => {
              :id   => @cinstance.plan.id,
              :name => @cinstance.plan.name
            },
            :account => {
              :id    => @cinstance.user_account.id,
              :name  => @cinstance.user_account.org_name
            },
            service: {
              id: @cinstance.service_id
            }
          }
        end

        return result if options.fetch(:skip_change, true)

        if granularity.to_s == 'day'
          previous_range = range.class.new(range.previous.begin.midnight, range.previous.end.midnight) # this is to keep us from breaking in DST.......
          previous_data = usage_values_in_range(previous_range, granularity, metric)
        else
          previous_data = usage_values_in_range(range.previous, granularity, metric)
        end
        previous_total = previous_data.sum
        result[:previous_total] = previous_total
        result[:change] = total.percentage_change_from(previous_total)

        result
      end

      def usage_progress(options)
        range, granularity, metric = extract_range_and_granularity_and_metric(options)

        current_data  = usage_values_in_range(range, granularity, metric) # can be Metric or ResponseCode
        previous_range = range.class.new(range.previous.begin.midnight, range.previous.end.midnight - 1) # this is to keep us from breaking in DST.......
        previous_data = usage_values_in_range(previous_range, granularity, metric) unless options[:skip_change]
        # previous_data = usage_values_in_range(range.previous, granularity, metric) unless options[:skip_change]
        total = current_data.sum
        previous_total = previous_data.sum

        rslt = {
          data: {
            total: total,
            values: current_data,
            previous_total: previous_total
          }
        }
        rslt.merge!(detail(metric))
        rslt.deep_merge!(data: { change: total.percentage_change_from(previous_total) }) unless options[:skip_change]
        rslt
      end

      def usage_progress_for_buyer_methods(options)
        #source.first => service, source.last => app
        methods = source.first.method_metrics.select do |method|
                    method.enabled_for_plan?(source.last.plan) &&
                      method.visible_in_plan?(source.last.plan)
        end

        usage_for_all(methods, options)
      end

      def usage_progress_for_all_methods(options)
        usage_for_all( source.first.method_metrics, options)
      end

      def usage_progress_for_all_metrics(options)
        usage_for_all( source.first.metrics.top_level, options)
      end

      private

      def usage_for_all(items, options)
        metrics = items.inject([]) do |memo, item|
          memo << usage_progress(options.merge(:metric => item))
        end
        {
          :period  => period_detail(options),
          :metrics => metrics
        }
      end

      def usage_values_in_range(range, granularity, metric)
        storage.values_in_range(range, granularity, [:stats, source_key, metric])
      end

      def extract_range_and_granularity_and_metric(options)
        options = options.symbolize_keys

        range, granularity = extract_range_and_granularity(options)
        validate_time_range(range, granularity)
        metric             = extract_metric(options)

        [range, granularity, metric]
      end

      def extract_range_and_granularity(options)
        if options[:period]
          period = sanitize_period(options[:period])
          granularity = options[:granularity] || GRANULARITIES[period]
          length = 1.send(period)

          timezone = extract_timezone(options)
          range_since = to_time(options[:since].presence || timezone.now - length, timezone)
          range_until = (range_since + length - 1.second).end_of_minute # taking a second away means excluding the extra day in case of a month, etc

          sanitize_range_and_granularity(range_since..range_until, granularity)
        else
          options.assert_required_keys!(:granularity)
          # due to the unfortunate use of 21600 as a valid granularity  the parameter is required to a symbol or fixnum
          raise InvalidParameterError, "Granularity must be one of #{ALLOWED_GRANULARITIES.inspect}, not #{options[:granularity]}" unless ALLOWED_GRANULARITIES.include?(options[:granularity]) || ALLOWED_GRANULARITIES.include?(options[:granularity].to_sym)

          if options[:since].present? && options[:until].present?
            timezone = extract_timezone(options)
            range = to_time(options[:since], timezone)..to_time(options[:until], timezone)
            sanitize_range_and_granularity(range, options[:granularity])
          elsif options[:range].present?
            sanitize_range_and_granularity(options[:range], options[:granularity])
          else
            raise InvalidParameterError, "You need to specify either 'range' or 'since' and 'until'"
          end

        end
      rescue ThreeScale::HashHacks::MissingKeyError => e
        raise InvalidParameterError, e.to_s
      end

      protected

      def sanitize_period(period)
        if GRANULARITIES.has_key?(period)
          return period
        else
          raise InvalidParameterError, "Period must be one of #{GRANULARITIES.keys.inspect} not #{period.inspect}"
        end
      end

      def sanitize_range_and_granularity(range, granularity)
        granularity = Stats::Aggregation.normalize_granularity(granularity)
        range = range.to_time_range.round(granularity)

        [range, granularity]
      end

      def validate_time_range(range, granularity)
        return unless ALLOWED_TIME_RANGES[granularity] && range.length > ALLOWED_TIME_RANGES[granularity]

        raise InvalidParameterError, "Time range for the granularity must be less than #{ALLOWED_TIME_RANGES[granularity].inspect}"
      end
    end
  end
end
