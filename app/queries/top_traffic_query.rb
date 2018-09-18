class TopTrafficQuery

  LIMIT = 5

  attr_reader :stats_client

  def initialize(stats_client)
    @stats_client = stats_client
  end

  def by_range(range:, cache_allowed: false)
    no_cache = ->(&block) { block.call }
    cached   = ->(&block) { cache(range, &block) }

    wrapper = cache_allowed ? cached : no_cache

    top_apps = wrapper.call do
      stats_data_for(range)
    end

    top_application_data_for(top_apps)
  end

  private

  def top_application_data_for(top_apps)
    top_apps  # { 123 => [1, 2], 456 => [2], 789 => [1] }
      .lazy
      .map { |(id, positions)| TopApplicationData.new(id, positions) }
      .sort # sorted by appearances/position ascending
      .reverse_each # take the ones with highest ranking (from the bottom)
  end

  def stats_data_for(range)
    top_clients_stats(range.to_a) # [{ 139=>[1], 138=>[2], 137=>[3] }, { 139=>[1], 138=>[2], 137=>[3] }]
      .compact
      .reduce({}) { |a, e| a.merge(e) { |_, old, new| old + new } } # { 123 => [1] + [2], 456 => [2], 789 => [1] }
  end

  def top_clients_stats(dates)
    multi_cache dates do |date|
      Rails.logger.debug { "[dashboard] loading stats for #{date} for metric hits"}

      stats_client
        .top_clients(metric_name: 'hits', since: date, period: 'day', timezone: 'UTC', limit: LIMIT)
        .fetch(:applications) # { applications: [ {id: 123, name: 'foo' }, { id: 456, name 'bar' } ] }
        .map.with_index(1, &method(:normalize_app)) # [ { 123 => [1] } , { 456 => [2] }]
        .reduce(&:merge) || {} # { 123 => [1], 456 => [2] }
      # return empty hash in case of empty response
    end
  end

  def normalize_app(app, position)
    { app.fetch(:id) => Array(position) }
  end

  def cache(dates, &block)
    cache = Rails.cache

    cache.fetch(dates, cache_options, &block)
  end

  def multi_cache(dates, &block)
    cache = Rails.cache

    # don't cache today, as it can still change
    past_dates = dates.reject { |date| date >= Time.zone.now.to_date }

    if cache.respond_to?(:fetch_multi)
      result = cache.fetch_multi(*past_dates, cache_options, &block)

      # Rails fetch_multi returns an array
      # Dalli fetch_multi returns a hash
      result.try(:values) || result
    else
      # TODO: Remove on Rails 4.1 where all stores support fetch_multi (including NullStore for tests)
      past_dates.map { |date| [date, cache.fetch(date, cache_options) { yield(date) }] }.to_h.values
    end
  end

  def cache_options
    {
      namespace:  cache_namespace,
      expires_in: 1.hour
    }
  end

  def cache_namespace
    ActiveSupport::Cache.expand_cache_key(
      [self.class.name, *stats_client.source],'v1/provider/dashboard'
    )
  end

  # Holds information about how many times the application was
  # in top N and on which position. Compares them by using appearances and position.
  class TopApplicationData
    attr_reader :id, :positions

    def initialize(id, positions) # 123, [1,2]
      @id        = id
      @positions = positions.flatten.freeze
    end

    # Average position
    def position
      Float(positions.sum) / appearances
    end

    # Number of appearances in top N
    def appearances
      positions.size
    end

    # Compare applications. First by number of appearances, then by average position.
    # @param other [Application]
    def <=>(other)
      by_appearance = appearances    <=> other.appearances
      by_position   = other.position <=> position # reverse comparison, smaller is better

      by_appearance.zero? ? by_position : by_appearance
    end
  end
end
