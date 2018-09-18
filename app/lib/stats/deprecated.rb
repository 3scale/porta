module Stats
  module Deprecated
    # This is just quick and dirty port of the old ugly API to the new API.
    # This should be replaced with some new shiny and awesome api as soon as posible.
    #
    # DO NOT ADD anything new here!
    # DO NOT USE this in a new code!
    #

    def self.usage(source, options)
      zone = extract_timezone(options)

      domain = domain_for(source)
      options[:year]  ||= zone.now.year

      if options[:day]
        range_since = zone.local(options[:year], options[:month], options[:day])
        range_until = range_since.end_of_day

        granularity = :hour
      elsif options[:week]
        range_since = zone.local(options[:year], 1, 1).beginning_of_week +
                        (options[:week].to_i - 1).weeks
        range_until = range_since.end_of_week

        granularity = 6.hours
      else
        options[:month] ||= zone.now.month

        range_since = zone.local(options[:year], options[:month], 1)
        range_until = range_since.end_of_month

        granularity = :day
      end

      range = (range_since..range_until).to_time_range
      data = domain.usage(:metric_name => options[:metric].name, :granularity => granularity,
                          :range => range)
      data = data[:values]
      [ActiveSupport::OrderedHash[*range.each(granularity).to_a.zip(data).flatten], range]
    end

    def self.average_usage_by_weekdays(service, options = {})
      domain = Stats::Service.new(service)

      range = options[:period] || Time.zone.last_month_range
      range = range.to_time_range

      weeks_count = range.length / 1.week

      data = domain.usage(:metric => options[:metric], :granularity => :day, :range => range)
      data = data[:values]
      data = range.each(:day).to_a.zip(data)

      data = data.group_by { |day, value| day.wday }
      data = data.sort_keys if data.is_a? ActiveSupport::OrderedHash # this doesnt apply in 1.9

      data.map_keys! { |wday| weekday_name(wday) }

      data.map_values! { |data_for_day| data_for_day.map(&:second) }
      data.map_values! { |values| values.sum.to_f / weeks_count }

      data
    end

    def self.average_usage_by_hours(service, options = {})
      zone = extract_timezone(options)
      domain = Stats::Service.new(service)

      range = options[:period] || zone.last_month_range
      range = range.to_time_range

      metric = options[:metric] || service.metrics.hits

      days_count = range.length / 1.day
      data = domain.usage(:metric => metric, :granularity => :hour,
                          :range => range, :timezone => options[:timezone])

      data = data[:values]
      data = range.each(:hour).to_a.zip(data)
      data = data.group_by { |day, value| day.hour }
      data = data.sort_keys if data.is_a? ActiveSupport::OrderedHash # this doesnt apply in 1.9

      data.map_values! { |data_for_day| data_for_day.map(&:second) }
      data.map_values! { |values| values.sum.to_f / days_count }

      format_hours(data)
    end

    def self.usage_in_day(service, options = {})
      raise InvalidParameterError, 'missing :day option' if options[:day].nil?
      raise InvalidParameterError, 'missing :metric option' if options[:metric].nil?

      domain = Stats::Service.new(service)

      range = options[:period] || Time.zone.current_month_range
      range = range.to_time_range

      range.each(options[:day].to_sym).inject(ActiveSupport::OrderedHash.new) do |memo, day|
        day_range = (day..day.end_of_day).to_time_range
        hours     = day_range.each(:hour).to_a

        data = domain.usage(:metric => options[:metric], :range => day_range,
                            :granularity => :hour)
        data = data[:values]

        memo[day] = ActiveSupport::OrderedHash[*hours.zip(data).flatten]
        memo
      end
    end

    private

    def self.domain_for(source)
      case source
      when ::Service then Stats::Service.new(source)
      when ::Cinstance then Stats::Client.new(source)
      else raise "Can't find stats domain for #{source.inspect}"
      end
    end

    def self.for_all_metrics(method)
      meta_class = class << self; self; end
      meta_class.instance_eval do
        define_method("#{method}_for_all_metrics") do |*args|
          call_for_all_metrics(method, args[0], args[1] || {})
        end
      end
    end

    def self.call_for_all_metrics(method, source, options)
      source.metrics.top_level.inject({}) do |memo, metric|
        memo[metric] = send(method, source, options.merge(:metric => metric))
        memo
      end
    end

    def self.date_labels(period, format)
      period.to_time_range.each(:day).map { |time| time.to_date.to_s(format) }
    end

    def self.weekday_name(number)
      %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday][number]
    end

    def self.format_hours(data)
      data.map_keys { |hour| format_hour(hour) }
    end

    def self.format_hour(hour)
      hour > 12 ? "#{hour - 12} pm" : "#{hour} am"
    end

    def self.extract_timezone(options)
      raise InvalidParameterError, 'missing :timezone option' unless options[:timezone]
      ActiveSupport::TimeZone.new(options[:timezone])
    end


    public

    for_all_metrics :usage
    for_all_metrics :top_users
    for_all_metrics :average_usage_by_weekdays
    for_all_metrics :average_usage_by_hours
  end
end
