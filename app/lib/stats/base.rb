
require_dependency 'stats'

module Stats
  class Base
    include ::Stats::KeyHelpers
    include ::ThreeScale::MethodTracing

    # TODO: Replace the zone default parameter by Time.zone once the
    # application's default zone is set to UTC
    DEFAULT_ZONE = ActiveSupport::TimeZone.new('UTC')

    def initialize(*sources)
      @source = sources
    end

    attr_reader :source

    def source_key
      source
    end

    def self.storage
      @storage ||= Storage.instance
    end

    def storage
      self.class.storage
    end

    private

    def detail(metric)
      case  metric
      when Metric
      {
        id: metric.id,
        name: metric.friendly_name,
        system_name: metric.system_name,
        unit: metric.unit
      }
      when ResponseCode
        { code: metric.code }
      end
    end

    def period_detail(options)
      range, granularity = extract_range_and_granularity(options)
      timezone = options[:timezone] ? extract_timezone(options) : range.begin.time_zone

      {
        name: options[:period],
        since: range.begin,
        until: range.end,
        timezone: (timezone || DEFAULT_ZONE).tzinfo.name, #tzinfo.name returns the 'Continent/Country' form
        granularity: granularity
      }
    end

    def extract_timezone(options)
      raise InvalidParameterError, 'missing :timezone option' unless options[:timezone]
      ActiveSupport::TimeZone.new(options[:timezone])
    end

    def to_time(stuff, zone = nil)
      zone ||= DEFAULT_ZONE
      return stuff if stuff.acts_like?(:time)
      begin
        zone.parse(stuff.to_s)
      rescue ArgumentError
        raise InvalidParameterError, 'Date parameters should have valid date/time format.'
      end
    end

    # Finds in options[:metric] options[:metric_name] or
    # options[:response_code]
    def extract_metric(options)
      unless options[:metric] || options[:metric_name] || options[:response_code]
        raise InvalidParameterError, "Missing key(s): metric_name"
      end

      metric = if options[:metric]
                 options[:metric]
               elsif m = metrics.find_by_system_name(options[:metric_name])
                 m
               elsif options[:response_code]
                 ResponseCode.new(options[:response_code])
               end

      if metric.nil?
        raise InvalidParameterError, "metric #{options[:metric_name]} not found"
      end

      metric
    end
    add_three_scale_method_tracer :extract_metric


    def extract_since(options)
      timezone = options[:timezone]
      since = options[:since]
      period = sanitize_period(options[:period])

      # parse :since in supplied timezone
      # use current time if no :since is given
      unless since.acts_like?(:time)
        raise InvalidParameterError.new('You have to supply :timezone if :since is not supplied as TimeWithZone') unless timezone
        timezone = ActiveSupport::TimeZone.new(timezone) if String === timezone
        since = since ? timezone.parse(since.to_s) : timezone.now
      end

      since.beginning_of(period.to_sym)
    end

    def metrics
      source.first.metrics
    end
  end
end
