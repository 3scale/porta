
module Stats
  class Storage < Backend::Storage
    include ::Stats::KeyHelpers
    include ::ThreeScale::MethodTracing
    include ActiveSupport::Benchmarkable
    delegate :logger, to: :Rails

    # TODO: - join with stats/views/usage
    #
    ALLOWED_GRANULARITIES = [ 6.hours, :hour, :day, :month ].freeze

    def values_in_range(range, granularity, prefix)
      # TODO: - refactor, isolate to strategies?
      case granularity
      when :day, :month
        use_aggregated_values(range, granularity, prefix)
      when 6.hours
        resum_all_value(range, granularity, prefix)
      when :hour
        range = range.to_time_range.utc
        keys = keys_for_range(range, granularity, prefix)
        if keys.empty?
          []
        else
          mget(*keys).map(&:to_i)
        end
      else
        raise InvalidParameterError, "Granularity #{options[:granularity]} not allowed (use #{ALLOWED_GRANULARITIES.inspect})"
      end
    end


    # TODO: calls for refactoring - options are magic argument without
    # semantic and client code then becomes tricky (use facades like
    # "stats_for_cinstance"?) Now, the user of storage has to study
    # key_for private method to undestand what arguments to supply.
    #
    def ordered_hash(since, period, options)
      raise InvalidParameterError, "'since' should be ActiveSupport::TimeWithZone" unless ActiveSupport::TimeWithZone === since

      options.assert_valid_keys(:from, :by, :order, :limit)
      options.assert_required_keys(:from, :by)

      source_key = key_for(options[:from])
      value_key  = key_for(options[:by].push(period => since.to_s(:compact)))
      value_key_without_period = value_key.match(/(.*)\/.*/)[1]

      begin
        sorted = sort(source_key, :by => value_key,
                         :order => options[:order] && options[:order].to_s.upcase,
                         :limit => options[:limit] && [0, options[:limit]],
                         :get =>  [ '#', value_key] )

        rslt = ActiveSupport::OrderedHash[*sorted.flatten] # grabbing both the sorted keys and their values

        # compute deltas to time shift each value
        range = (since..(since + granularity_to_hours(period))).to_time_range
        shift = range.shift_in_hours

        if shift != 0
          rslt.each do |key,val|
            prefix = value_key_without_period.gsub('*', key.to_s)
            deltas = compute_timeshift_deltas(range, shift, period, prefix)
            rslt[key] = timeshift_values_by_deltas( shift, [ val.to_i ], deltas, period)[0]
          end
        end

        rslt
      rescue RuntimeError => e # "no such key" for example
        System::ErrorReporting.report_error(e) if Rails.env.production?
        ActiveSupport::OrderedHash.new
      end
    end
    add_three_scale_method_tracer :ordered_hash

    protected

    # Brute force version - does not use other granularities than
    # hours: sums them up to get the bigger granularity.
    #
    def resum_all_value(range, granularity, prefix)
      g = granularity_to_seconds(granularity)

      range = range.to_time_range.utc
      prefix = key_for(prefix) + '/hour:'

      range.each(g).map do |from|
        # day_prefix = from.beginning_of(:day).to_s(:compact)
        to = from + (g - 3600)
        keys = (from..to).to_time_range.each(:hour).map do |time|
          prefix + time.to_s(:compact)
        end

        mget(*keys).inject(0) { |sum,v| sum + v.to_i }
      end
    end

    # More sofisticated algorithm of getting stats: uses the aggregated values in Redis
    # and adjusts them according to time shifts.
    #
    def use_aggregated_values(range, granularity, prefix)
      range = range.to_time_range
      keys = keys_for_range(range, granularity, prefix)
      values = if keys.empty?
                 []
               else
                 mget(*keys).map(&:to_i)
               end
      shift = range.shift_in_hours

      if shift == 0
        values
      else
        deltas = compute_timeshift_deltas(range, shift, granularity, prefix)
        timeshift_values_by_deltas(shift, values, deltas, granularity)
      end
    end

    private


    # Adjusts +values+ by deltas according to shift. That means, for
    # example when values are per days and time shift +2(hours), that
    # value for each day will substract be of 'deltas' from
    #
    # +deltas+ array has to be 1 element longer then +values+ on
    # each side so that the equation works
    #
    # +shift+ is expected to be in hours
    #
    def timeshift_values_by_deltas(shift, values, deltas, granularity)
      values = values.each.with_index

      # HACK!!
      # FIXME: having a different one just for months it's horrible but we'll fix it later, the days are dodgy
      if granularity == :month
        values.map do |value, i|
          current_delta = deltas.fetch(i, 0)
          next_delta = deltas.fetch(i+1, 0)

          if shift > 0
            value + current_delta - next_delta
          else
            value - current_delta + next_delta
          end
        end
      else
        add_index = shift > 0 ? 0 : 2

        values.map do |value, i|
          shifted_delta = deltas.fetch(i + add_index, 0)
          next_delta = deltas.fetch(i+1, 0)
          value + shifted_delta - next_delta
        end
      end
    end

    #
    # Used for optimized key construction in #overflowing_hours method
    HOURS_STRINGS  = ["","01", "02", "03", "04", "05", "06", "07", "08", "09", "1",
                      "11", "12", "13", "14", "15", "16", "17", "18", "19", "2",
                      "21", "22", "23"]


    # gets hits in +shift+ hours at the (beginning - 1 granularity) and (end +
    # 1 granularity) of the range with specified by options
    #
    def compute_timeshift_deltas(range, shift, granularity, prefix)
      raise InvalidParameterError, 'You do not need to call this method for UTC zone (shift == 0)' if shift == 0

      prefix = key_for(prefix) + '/hour:'
      if granularity == :month # this fixes the behaviour for yearly charts
        granularity = granularity_to_seconds(:day)
        beginning_of_range = range.begin.beginning_of_month
        if shift > 0
          granularity_for_iteration = :end_of_month
        else # negative time zones
          granularity_for_iteration = :month
          beginning_of_range += granularity # this is needed otherwise the shifted_range will snap to the wrong date
        end
      else
        granularity = granularity_to_seconds(granularity)
        beginning_of_range = range.begin
        granularity_for_iteration = granularity
      end

      shifted_range = ((beginning_of_range - granularity)..(range.end + granularity)).to_time_range

      # should we use 'evening' or 'morning' margins?
      margin = (shift < 0) ?  (0...shift.abs) : ((24 - shift.abs)..23)

      keys = benchmark :shifted_range, level: :debug do
        shifted_range.each(granularity_for_iteration).flat_map do |date|
          prefix_with_day = prefix + date.beginning_of(:day).to_s(:compact)

          margin.map do |hour|
            prefix_with_day + HOURS_STRINGS[hour]
          end
        end
      end

      benchmark "mget #{keys.count} keys in groups of #{margin.count}", level: :debug do
        # we grabbed a list of all keys before, but when parsing the data, we must first split in groups of shifted ranges (example: days) and only then we can sum
        mget(*keys).in_groups_of(margin.count).map do |i|
          i.inject(0) do |sum,value|
            sum + value.to_i
          end
        end
      end
    end
    add_three_scale_method_tracer :compute_timeshift_deltas

    # Gets keys in given range for :granularity supplied in options
    #
    def keys_for_range(range, granularity, key_prefix)
      key = key_for(key_prefix)
      prefix = key + '/' + granularity.to_s + ':'
      transform = ->(time) { prefix + time.to_s(:compact) }

      case granularity
      when :day
        from = range.begin.to_date
        to = range.end.to_date
        Range.new(from, to).map(&transform)
      else
        benchmark "keys_for_range #{range} (#{granularity})", level: :debug do
          range.to_time_range.each(granularity).map(&transform)
        end
      end
    end

    add_three_scale_method_tracer :keys_for_range

    def granularity_to_seconds(g)
      (g.is_a?(Symbol) || g.is_a?(String)) ? 1.public_send(g) : g
    end

    def granularity_to_hours(g)
      granularity_to_seconds(g) / 3600
    end

  end
end
